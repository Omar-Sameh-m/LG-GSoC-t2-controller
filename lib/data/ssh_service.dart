import 'package:dartssh2/dartssh2.dart';
import 'package:lg_flutter_app/data/kml_maker.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SSH Service for communicating with the Liquid Galaxy master machine.
///
/// This service handles all SSH connections and commands sent to the LG rig.
/// The LG system works by:
/// 1. Connecting to the master machine (lg1) via SSH
/// 2. Writing KML files to /var/www/html/ (served by Apache)
/// 3. Updating kmls.txt files to tell each screen what to display
/// 4. Sending fly-to commands via /tmp/query.txt
///
/// The master machine syncs content to slave machines (lg2, lg3, etc.)
/// which display on individual screens arranged in a panoramic setup.
class SshService {
  /// SSH client instance - null when not connected
  SSHClient? _client;

  /// Sudo password for executing privileged commands on LG.
  ///
  /// Required for:
  /// - Creating directories in /var/www/html/
  /// - Setting file permissions
  /// - Restarting Apache service
  /// - Removing files owned by www-data
  static const String sudoPassword = 'lqgalaxy';

  /// Establishes SSH connection to the LG master machine.
  ///
  /// Connection parameters are read from SharedPreferences (saved from
  /// the connection form in HomeScreen). If no saved values exist,
  /// defaults from AppConstants are used.
  ///
  /// Returns true if connection successful, false otherwise.
  ///
  /// The connection timeout is set to 5 seconds to fail fast if
  /// the LG machine is not reachable.
  Future<bool> connect() async {
    // Load saved connection settings from device storage
    final prefs = await SharedPreferences.getInstance();
    final ip = prefs.getString('ip') ?? '192.168.1.10';
    final port = int.parse(prefs.getString('port') ?? '22');
    final user = prefs.getString('username') ?? 'lg';
    final pass = prefs.getString('password') ?? 'lg';

    try {
      // Establish TCP socket connection to SSH port
      final socket = await SSHSocket.connect(
        ip,
        port,
        timeout: const Duration(seconds: 5),
      );

      // Create SSH client with password authentication
      _client = SSHClient(
        socket,
        username: user,
        onPasswordRequest: () => pass,
      );

      print('Connected to LG Master at $ip');
      return true;
    } catch (e) {
      print('Connection failed: $e');
      return false;
    }
  }

  /// Sends a logo image to the left screen (slave 3) of the LG rig.
  ///
  /// This method:
  /// 1. Creates /var/www/html/kml/ directory if it doesn't exist
  /// 2. Writes a KML file with a ScreenOverlay pointing to the logo image
  /// 3. Updates kmls_3.txt to tell lg3 to display this KML
  /// 4. Restarts Apache to clear any cached content
  ///
  /// The logo appears only on the leftmost screen (lg3) in a 3-screen setup.
  ///
  /// [kmlContent] - The KML string containing the screen overlay
  /// [logoUrl] - Optional custom logo URL (uses default LG logo if null)
  Future<bool> sendLogo(String kmlContent, {String? logoUrl}) async {
    if (_client == null) return false;

    try {
      // Use provided logo URL or fall back to default LG logo
      final logoImageUrl =
          logoUrl ??
          'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEgXmdNgBTXup6bdWew5RzgCmC9pPb7rK487CpiscWB2S8OlhwFHmeeACHIIjx4B5-Iv-t95mNUx0JhB_oATG3-Tq1gs8Uj0-Xb9Njye6rHtKKsnJQJlzZqJxMDnj_2TXX3eA5x6VSgc8aw/s320-rw/LOGO+LIQUID+GALAXY-sq1000-+OKnoline.png';

      // Replace placeholder with actual logo URL in KML content
      final kmlWithLogo = kmlContent.replaceAll(
        'assets/lg_logo.png',
        logoImageUrl,
      );

      // Use HERE document to write multi-line KML to file
      // This avoids complex quote escaping in shell commands
      final writeCmd =
          '''
cat > /var/www/html/kml/slave_3.kml << 'EOF'
$kmlWithLogo
EOF''';

      // Execute commands on LG master via SSH
      await _client!.run(
        "echo '$sudoPassword' | sudo -S mkdir -p /var/www/html/kml",
      );
      await _client!.run(
        "echo '$sudoPassword' | sudo -S chmod -R 777 /var/www/html/kml",
      );
      await _client!.run(writeCmd);

      // Tell slave 3 (left screen) to load this KML
      // 10.42.42.1 is the internal IP of the master machine
      await _client!.run(
        "echo 'http://10.42.42.1:81/kml/slave_3.kml' > /var/www/html/kmls_3.txt",
      );

      // Restart Apache to force cache clear and apply changes
      await _client!.run(
        "echo '$sudoPassword' | sudo -S service apache2 restart",
      );

      return true;
    } catch (e) {
      print('Error sending logo: $e');
      return false;
    }
  }

  /// Removes the logo from the left screen (slave 3).
  ///
  /// This method:
  /// 1. Deletes the slave_3.kml file
  /// 2. Removes the entry from kmls_3.txt using sed
  /// 3. Restarts Apache to apply changes
  ///
  /// Other KMLs (like the pyramid) are preserved - only the logo is removed.
  Future<bool> cleanLogo() async {
    if (_client == null) return false;

    try {
      // Remove the logo KML file
      await _client!.run(
        "echo '$sudoPassword' | sudo -S rm -f /var/www/html/kml/slave_3.kml",
      );

      // Remove logo entry from kmls_3.txt (sed deletes lines matching pattern)
      await _client!.run("sed -i '/slave_3.kml/d' /var/www/html/kmls_3.txt");

      // Restart Apache to clear cache
      await _client!.run(
        "echo '$sudoPassword' | sudo -S service apache2 restart",
      );

      return true;
    } catch (e) {
      print('Error cleaning logo: $e');
      return false;
    }
  }

  /// Sends a KML file to the LG master for display.
  ///
  /// This is a general-purpose method for sending any KML content.
  /// The KML is written to /var/www/html/ and added to the specified
  /// index file which controls what displays on the screens.
  ///
  /// [kmlContent] - The KML XML string to send
  /// [fileName] - Name for the KML file (e.g., "pyramid.kml")
  /// [indexFile] - The index file to update (default: kmls.txt)
  /// [host] - The hostname for the URL (default: lg1)
  Future<void> sendKML(
    String kmlContent,
    String fileName, {
    String indexFile = 'kmls.txt',
    String host = 'lg1',
  }) async {
    if (_client == null) return;

    try {
      // Escape single quotes in KML to prevent shell injection issues
      final safeKml = kmlContent.replaceAll("'", "'\\''");

      // Write KML content to file
      await _client!.run("echo '$safeKml' > /var/www/html/$fileName");

      // Add to index file so Google Earth loads it
      await _client!.run(
        "echo 'http://$host:81/$fileName' > /var/www/html/$indexFile",
      );
    } catch (e) {
      print('Error sending KML: $e');
    }
  }

  /// Sends a fly-to command to navigate Google Earth to specific coordinates.
  ///
  /// The fly-to command is written to /tmp/query.txt which Google Earth
  /// monitors for navigation instructions. This allows programmatic
  /// control of the camera position.
  ///
  /// [lat] - Latitude in decimal degrees
  /// [lng] - Longitude in decimal degrees
  /// [zoom] - Camera range/altitude in meters (lower = closer)
  /// [tilt] - Camera tilt in degrees (0 = top-down, 90 = horizon)
  /// [heading] - Camera heading in degrees (0 = north, 90 = east)
  Future<void> flyTo(
    double lat,
    double lng,
    double zoom,
    double tilt,
    double heading,
  ) async {
    if (_client == null) return;

    try {
      // Generate KML LookAt element for the fly-to view
      final flyToCmd =
          'echo "flytoview=${KMLMaker.lookAtLinear(lat, lng, zoom, tilt, heading)}" > /tmp/query.txt';

      await _client!.run(flyToCmd);
    } catch (e) {
      print('FlyTo failed: $e');
    }
  }

  /// Clears all KMLs from the LG display.
  ///
  /// This empties the kmls.txt index file, causing Google Earth to
  /// unload all KML overlays and return to a clean state.
  Future<void> cleanSlaves() async {
    if (_client == null) return;

    try {
      // Empty the index file - Google Earth will unload all KMLs
      await _client!.run("echo '' > /var/www/html/kmls.txt");
    } catch (e) {
      print('Clean failed: $e');
    }
  }

  /// Closes the SSH connection.
  ///
  /// Should be called when the app is closed or when disconnecting
  /// from the LG system to free network resources.
  void disconnect() {
    _client?.close();
    print('Disconnected from LG');
  }
}
