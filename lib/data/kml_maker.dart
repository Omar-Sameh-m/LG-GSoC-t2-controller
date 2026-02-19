/// Utility class for generating KML (Keyhole Markup Language) content.
///
/// KML is an XML-based format used by Google Earth to display geographic
/// data, 3D models, overlays, and camera views. This class provides
/// factory methods to create KML strings that control the LG display.
///
/// The LG (Liquid Galaxy) system uses KML to:
/// - Display image overlays (logos) on specific screens
/// - Position the camera (fly-to commands)
/// - Render 3D geometric shapes (pyramids, buildings)
class KMLMaker {
  /// Creates a KML ScreenOverlay for displaying an image on screen.
  ///
  /// ScreenOverlays are 2D images that float on top of the 3D globe view.
  /// They're used for logos, legends, and UI elements. This method creates
  /// a KML that positions the image in the lower-left area of the screen.
  ///
  /// [imageUrl] - URL of the image to display (must be accessible from LG)
  /// [factor] - Size scaling factor (currently unused, kept for API compatibility)
  ///
  /// Returns a complete KML Document with a ScreenOverlay element.
  ///
  /// The overlay is positioned at:
  /// - screenXY: 2% from left, 72.5% from bottom (lower-left area)
  /// - size: 554x500 pixels (fixed size for LG logo)
  static String screenOverlayImage(String imageUrl, double factor) {
    return '''<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
<Document>
    <name>Logo</name>
    <ScreenOverlay>
        <name>Logo</name>
        <visibility>1</visibility>
        <Icon>
          <href>$imageUrl</href>
        </Icon>
        <overlayXY x="0" y="0" xunits="fraction" yunits="fraction"/>
        <screenXY x="0.02" y="0.725" xunits="fraction" yunits="fraction"/>
        <rotationXY x="0" y="0" xunits="fraction" yunits="fraction"/>
        <size x="554" y="500" xunits="pixels" yunits="pixels"/>
    </ScreenOverlay>
</Document>
</kml>''';
  }

  /// Generates a KML LookAt element for camera positioning.
  ///
  /// LookAt defines the camera view in Google Earth with:
  /// - longitude/latitude: Where to look (center point)
  /// - range: Distance from ground in meters (zoom level)
  /// - tilt: Camera angle (0 = straight down, 90 = horizon)
  /// - heading: Compass direction (0 = north, 90 = east)
  ///
  /// This is used in fly-to commands to navigate the view.
  /// The gx:altitudeMode is set to relativeToGround for consistent behavior.
  ///
  /// [lat] - Target latitude
  /// [lng] - Target longitude
  /// [zoom] - Camera range in meters (smaller = closer)
  /// [tilt] - Tilt angle in degrees
  /// [heading] - Heading angle in degrees
  static String lookAtLinear(
    double lat,
    double lng,
    double zoom,
    double tilt,
    double heading,
  ) {
    return '<LookAt><longitude>$lng</longitude><latitude>$lat</latitude><range>$zoom</range><tilt>$tilt</tilt><heading>$heading</heading><gx:altitudeMode>relativeToGround</gx:altitudeMode></LookAt>';
  }

  /// Generates a 3D pyramid KML positioned above Cairo, Egypt.
  ///
  /// This creates a colorful 3D pyramid using KML Polygons with:
  /// - A square base at ground level (altitude = 0)
  /// - Four triangular faces meeting at a peak (altitude = 300m)
  /// - Different colors for each face for visual distinction
  ///
  /// The pyramid is positioned near the Giza Pyramids coordinates
  /// (defined in AppConstants) as a demonstration of 3D KML capabilities.
  ///
  /// Each face is a separate Placemark with:
  /// - Polygon geometry with 4 coordinates (3 corners + close the ring)
  /// - altitudeMode: relativeToGround (height above terrain)
  /// - extrude: 0 (no connection to ground)
  ///
  /// Returns a complete KML Document with the 3D pyramid.
  static String generatePyramid() {
    return '''<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
<Document>
  <name>GSoC Pyramid</name>
  
  <Style id="pyramidBase">
    <LineStyle><color>ff0000ff</color><width>2</width></LineStyle>
    <PolyStyle><color>dd00ff00</color></PolyStyle>
  </Style>
  
  <Style id="pyramidFace1">
    <LineStyle><color>ffff0000</color><width>2</width></LineStyle>
    <PolyStyle><color>ddff0000</color></PolyStyle>
  </Style>
  
  <Style id="pyramidFace2">
    <LineStyle><color>ff00ff00</color><width>2</width></LineStyle>
    <PolyStyle><color>dd00ff00</color></PolyStyle>
  </Style>
  
  <Style id="pyramidFace3">
    <LineStyle><color>ffffff00</color><width>2</width></LineStyle>
    <PolyStyle><color>ddffff00</color></PolyStyle>
  </Style>
  
  <Style id="pyramidFace4">
    <LineStyle><color>ffff00ff</color><width>2</width></LineStyle>
    <PolyStyle><color>ddff00ff</color></PolyStyle>
  </Style>

  <!-- Base -->
  <Placemark>
    <name>Pyramid Base</name>
    <styleUrl>#pyramidBase</styleUrl>
    <Polygon>
      <extrude>0</extrude>
      <altitudeMode>relativeToGround</altitudeMode>
      <outerBoundaryIs>
        <LinearRing>
          <coordinates>
            31.137,29.974,0
            31.143,29.974,0
            31.143,29.980,0
            31.137,29.980,0
            31.137,29.974,0
          </coordinates>
        </LinearRing>
      </outerBoundaryIs>
    </Polygon>
  </Placemark>

  <!-- Face 1 (North) -->
  <Placemark>
    <name>Pyramid Face North</name>
    <styleUrl>#pyramidFace1</styleUrl>
    <Polygon>
      <extrude>0</extrude>
      <altitudeMode>relativeToGround</altitudeMode>
      <outerBoundaryIs>
        <LinearRing>
          <coordinates>
            31.137,29.974,0
            31.143,29.974,0
            31.140,29.977,300
            31.137,29.974,0
          </coordinates>
        </LinearRing>
      </outerBoundaryIs>
    </Polygon>
  </Placemark>

  <!-- Face 2 (East) -->
  <Placemark>
    <name>Pyramid Face East</name>
    <styleUrl>#pyramidFace2</styleUrl>
    <Polygon>
      <extrude>0</extrude>
      <altitudeMode>relativeToGround</altitudeMode>
      <outerBoundaryIs>
        <LinearRing>
          <coordinates>
            31.143,29.974,0
            31.143,29.980,0
            31.140,29.977,300
            31.143,29.974,0
          </coordinates>
        </LinearRing>
      </outerBoundaryIs>
    </Polygon>
  </Placemark>

  <!-- Face 3 (South) -->
  <Placemark>
    <name>Pyramid Face South</name>
    <styleUrl>#pyramidFace3</styleUrl>
    <Polygon>
      <extrude>0</extrude>
      <altitudeMode>relativeToGround</altitudeMode>
      <outerBoundaryIs>
        <LinearRing>
          <coordinates>
            31.143,29.980,0
            31.137,29.980,0
            31.140,29.977,300
            31.143,29.980,0
          </coordinates>
        </LinearRing>
      </outerBoundaryIs>
    </Polygon>
  </Placemark>

  <!-- Face 4 (West) -->
  <Placemark>
    <name>Pyramid Face West</name>
    <styleUrl>#pyramidFace4</styleUrl>
    <Polygon>
      <extrude>0</extrude>
      <altitudeMode>relativeToGround</altitudeMode>
      <outerBoundaryIs>
        <LinearRing>
          <coordinates>
            31.137,29.980,0
            31.137,29.974,0
            31.140,29.977,300
            31.137,29.980,0
          </coordinates>
        </LinearRing>
      </outerBoundaryIs>
    </Polygon>
  </Placemark>
</Document>
</kml>''';
  }
}
