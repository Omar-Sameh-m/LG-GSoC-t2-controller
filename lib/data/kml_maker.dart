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
                <description>LG Master Logo</description>
                <Icon>
                    <href>$imageUrl</href>
                </Icon>
                <overlayXY x="0.5" y="0.5" xunits="fraction" yunits="fraction"/>
                <screenXY x="0.5" y="0.5" xunits="fraction" yunits="fraction"/>
                <rotationXY x="0.5" y="0.5" xunits="fraction" yunits="fraction"/>
                <size x="800" y="600" xunits="pixels" yunits="pixels"/>
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
    // 3D pyramid with vibrant colors above cairo
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
            31.233,30.042,0
            31.239,30.042,0
            31.239,30.048,0
            31.233,30.048,0
            31.233,30.042,0
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
            31.233,30.042,0
            31.239,30.042,0
            31.236,30.045,300
            31.233,30.042,0
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
            31.239,30.042,0
            31.239,30.048,0
            31.236,30.045,300
            31.239,30.042,0
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
            31.239,30.048,0
            31.233,30.048,0
            31.236,30.045,300
            31.239,30.048,0
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
            31.233,30.048,0
            31.233,30.042,0
            31.236,30.045,300
            31.233,30.048,0
          </coordinates>
        </LinearRing>
      </outerBoundaryIs>
    </Polygon>
  </Placemark>
</Document>
</kml>''';
  }
}
