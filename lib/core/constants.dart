/// Application-wide constants for the LG Controller.
///
/// This class contains default configuration values and geographic coordinates
/// used throughout the app. All values are static constants that can be
/// accessed without instantiating the class.
class AppConstants {
  /// Default IP address for the LG master machine.
  ///
  /// Liquid Galaxy rigs typically use 192.168.1.10 as the master node
  /// that controls all slave screens. This is the entry point for SSH
  /// connections.
  static const String defaultIp = "192.168.1.10";

  /// Default SSH port (22 is standard for SSH).
  ///
  /// Port 22 is the default SSH port. Only change this if the LG master
  /// has been configured to use a non-standard SSH port.
  static const int defaultPort = 22;

  /// Default username for SSH authentication.
  ///
  /// 'lg' is the standard username for Liquid Galaxy machines.
  /// This user has permissions to write to /var/www/html/ and
  /// control the display system.
  static const String defaultUser = "lg";

  /// Default password for SSH authentication.
  ///
  /// 'lg' is the default password matching the username.
  /// In production, this should be changed for security.
  static const String defaultPass = "lg";

  /// Latitude of Giza Pyramids, Cairo, Egypt.
  ///
  /// Used as the default "home" location for fly-to operations.
  /// The pyramid KML is positioned at these coordinates.
  static const double cairoLat = 29.9753;

  /// Longitude of Giza Pyramids, Cairo, Egypt.
  ///
  /// Paired with cairoLat to form the complete coordinate pair
  /// for the pyramid location in Google Earth.
  static const double cairoLong = 31.1394;
}
