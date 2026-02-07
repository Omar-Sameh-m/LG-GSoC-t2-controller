import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lg_flutter_app/core/constants.dart';
import 'package:lg_flutter_app/data/kml_maker.dart';
import 'package:lg_flutter_app/data/ssh_service.dart';
import 'package:lg_flutter_app/logic/cubit/lg_state.dart';

class LgCubit extends Cubit<LgState> {
  final SshService _sshService;

  LgCubit(this._sshService) : super(LgInitial());

  Future<void> connectToLg() async {
    emit(LgConnecting());
    bool success = await _sshService.connect();
    if (success) {
      emit(LgConnected());
    } else {
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
  }

  Future<void> cleanKml() async {
    await _sshService.cleanSlaves();
    emit(LgActionSuccess(message: "KMLs Cleaned"));
  }

  Future<void> cleanLogos() async {
    await _sshService.sendKML("", "logo.kml");
    emit(LgActionSuccess(message: "Logos Cleaned"));
  }

  Future<void> sendLogoFromUrl(String url) async {
    String logoKml = KMLMaker.screenOverlayImage(url, 0.5);
    await _sshService.sendKML(logoKml, "logo.kml");
    emit(LgActionSuccess(message: "Custom Logo Sent!"));
  }

  Future<void> sendCustomKml(String kmlText, String filename) async {
    await _sshService.sendKML(kmlText, filename);
    emit(LgActionSuccess(message: "Custom KML Sent as $filename"));
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
  }
}
