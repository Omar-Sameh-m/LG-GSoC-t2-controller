import 'package:dartssh2/dartssh2.dart';
import 'package:lg_flutter_app/data/kml_maker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SshService {
  SSHClient? _client;

  Future<bool> connect() async {
    final prefs = await SharedPreferences.getInstance();
    final ip = prefs.getString('ip') ?? '192.168.0.101';
    final port = int.parse(prefs.getString('port') ?? '22');
    final user = prefs.getString('username') ?? 'lg';
    final pass = prefs.getString('password') ?? 'lg';

    try {
      final socket = await SSHSocket.connect(
        ip,
        port,
        timeout: const Duration(seconds: 5),
      );
      _client = SSHClient(
        socket,
        username: user,
        onPasswordRequest: () => pass,
      );
      print('Connected to LG');
      return true;
    } catch (e) {
      print('Connection failed: $e');
      return false;
    }
  }

  Future<void> sendKML(String kmlContent, String fileName) async {
    if (_client == null) return;
    try {
      await _client!.run("echo '$kmlContent' > /var/www/html/$fileName");
      await _client!.run(
        "echo 'http://lg1:81/$fileName' > /var/www/html/kmls.txt",
      );
    } catch (e) {
      print('Error sending KML: $e');
    }
  }

  Future<void> flyTo(
    double lat,
    double lng,
    double zoom,
    double tilt,
    double heading,
  ) async {
    if (_client == null) return;
    try {
      final flyToCmd =
          'echo "flytoview=${KMLMaker.lookAtLinear(lat, lng, zoom, tilt, heading)}" > /tmp/query.txt';
      await _client!.run(flyToCmd);
    } catch (e) {
      print('FlyTo failed: $e');
    }
  }

  Future<void> cleanSlaves() async {
    if (_client == null) return;
    try {
      await _client!.run("echo '' > /var/www/html/kmls.txt");
    } catch (e) {
      print('Clean failed: $e');
    }
  }

  void disconnect() {
    _client?.close();
  }
}
