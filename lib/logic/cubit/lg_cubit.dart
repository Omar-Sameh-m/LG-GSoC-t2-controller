import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lg_flutter_app/core/constants.dart';
import 'package:lg_flutter_app/data/kml_maker.dart';
import 'package:lg_flutter_app/data/ssh_service.dart';
import 'package:lg_flutter_app/logic/cubit/lg_state.dart';

class LgCubit extends Cubit<LgState> {
  final SshService _sshService;
  bool _isConnected = false;

  LgCubit(this._sshService) : super(LgInitial());

  bool get isConnected => _isConnected;

  Future<void> connectToLg() async {
    emit(LgConnecting());
    bool success = await _sshService.connect();
    if (success) {
      _isConnected = true;
      emit(LgConnected());
    } else {
      _isConnected = false;
      emit(LgError(message: 'Failed to connect to LG'));
    }
  }

  Future<void> sendLogos() async {
    String logoKml = KMLMaker.screenOverlayImage(
      "https://raw.githubusercontent.com/lucisays/imagen/main/LGMasterWebAppLogo.png",
      0.5,
    );
    await _sshService.sendKML(logoKml, "logo.kml");
    emit(LgActionSuccess(message: "Logo Sent!"));
    if (_isConnected) emit(LgConnected());
  }

  Future<void> sendPyramid() async {
    String pyramidKml = KMLMaker.generatePyramid();
    await _sshService.sendKML(pyramidKml, "pyramid.kml");
    await _sshService.flyTo(
      AppConstants.cairoLat,
      AppConstants.cairoLong,
      1000,
      45,
      0,
    );
    emit(LgActionSuccess(message: "Pyramid Sent & View Updated!"));
    if (_isConnected) emit(LgConnected());
  }

  Future<void> flyToCairo() async {
    await _sshService.flyTo(
      AppConstants.cairoLat,
      AppConstants.cairoLong,
      5000,
      0,
      0,
    );
    emit(LgActionSuccess(message: "Flying to Cairo..."));
    if (_isConnected) emit(LgConnected());
  }

  Future<void> cleanKml() async {
    await _sshService.cleanSlaves();
    emit(LgActionSuccess(message: "KMLs Cleaned"));
    if (_isConnected) emit(LgConnected());
  }

  Future<void> cleanLogos() async {
    await _sshService.sendKML("", "logo.kml");
    emit(LgActionSuccess(message: "Logos Cleaned"));
    if (_isConnected) emit(LgConnected());
  }

  Future<void> sendLogoFromUrl(String url) async {
    String logoKml = KMLMaker.screenOverlayImage(url, 0.5);
    await _sshService.sendKML(logoKml, "logo.kml");
    emit(LgActionSuccess(message: "Custom Logo Sent!"));
    if (_isConnected) emit(LgConnected());
  }

  Future<void> sendCustomKml(String kmlText, String filename) async {
    await _sshService.sendKML(kmlText, filename);
    emit(LgActionSuccess(message: "Custom KML Sent as $filename"));
    if (_isConnected) emit(LgConnected());
  }

  Future<void> flyToCoordinates(
    double lat,
    double lon,
    double altitude,
    double heading,
    double tilt,
  ) async {
    await _sshService.flyTo(lat, lon, altitude, heading, tilt);
    emit(LgActionSuccess(message: "Flying to ($lat, $lon)"));
    if (_isConnected) emit(LgConnected());
  }
}
