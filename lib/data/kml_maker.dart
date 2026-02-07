class KMLMaker {
  static String screenOverlayImage(String imageUrl, double factor) {
    return '''<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
    <Document>
        <name>LG Logo Overlay</name>
        <Folder>
            <name>Logo</name>
            <ScreenOverlay>
                <name>Logo</name>
                <Icon>
                    <href>$imageUrl</href>
                </Icon>
                <overlayXY x="0" y="1" xunits="fraction" yunits="fraction"/>
                <screenXY x="0.02" y="0.95" xunits="fraction" yunits="fraction"/>
                <rotationXY x="0" y="0" xunits="fraction" yunits="fraction"/>
                <size x="500" y="400" xunits="pixels" yunits="pixels"/>
            </ScreenOverlay>
        </Folder>
    </Document>
</kml>''';
  }

  static String lookAtLinear(
    double lat,
    double lng,
    double zoom,
    double tilt,
    double heading,
  ) {
    return '<LookAt><longitude>$lng</longitude><latitude>$lat</latitude><range>$zoom</range><tilt>$tilt</tilt><heading>$heading</heading><gx:altitudeMode>relativeToGround</gx:altitudeMode></LookAt>';
  }

  static String generatePyramid() {
    // colored pyramid above cairo
    return '''<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
<Document>
  <name>GSoC Pyramid</name>
  <Style id="yellowPoly">
    <LineStyle><color>7f7faaaa</color><width>4</width></LineStyle>
    <PolyStyle><color>7f00ffff</color></PolyStyle>
  </Style>
  <Placemark>
    <name>Cairo Pyramid</name>
    <styleUrl>#yellowPoly</styleUrl>
    <Polygon>
      <extrude>1</extrude>
      <altitudeMode>relativeToGround</altitudeMode>
      <outerBoundaryIs>
        <LinearRing>
          <coordinates>
            31.235,30.044,0
            31.238,30.044,0
            31.238,30.047,0
            31.235,30.047,0
            31.235,30.044,0
          </coordinates>
        </LinearRing>
      </outerBoundaryIs>
      <innerBoundaryIs>
        <LinearRing>
          <coordinates>
            31.2365,30.0455,200
            31.2365,30.0455,200
            31.2365,30.0455,200
            31.2365,30.0455,200
            31.2365,30.0455,200
          </coordinates>
        </LinearRing>
      </innerBoundaryIs>
    </Polygon>
  </Placemark>
</Document>
</kml>''';
  }
}
