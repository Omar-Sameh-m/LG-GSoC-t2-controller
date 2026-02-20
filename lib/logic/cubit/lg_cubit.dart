import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lg_flutter_app/core/constants.dart';
import 'package:lg_flutter_app/data/kml_maker.dart';
import 'package:lg_flutter_app/data/ssh_service.dart';
import 'package:lg_flutter_app/logic/cubit/lg_state.dart';

/// Business Logic Component (BLoC) for managing LG connection and actions.
///
/// The LgCubit sits between the UI (HomeScreen) and the data layer (SshService).
/// It manages the connection state and coordinates all actions sent to the
/// Liquid Galaxy rig.
///
/// State Management Flow:
/// 1. UI calls cubit method (e.g., cubit.sendLogos())
/// 2. Cubit performs the action via SshService
/// 3. Cubit emits state changes (LgActionSuccess, then LgConnected)
/// 4. UI reacts to states (shows snackbars, enables/disables buttons)
///
/// The cubit maintains an internal _isConnected flag to track whether
/// the SSH connection is active. This is separate from the emitted states
/// and is used to determine if actions should be allowed.
class LgCubit extends Cubit<LgState> {
  /// SSH service for communicating with the LG master machine.
  /// Injected via constructor for testability and loose coupling.
  final SshService _sshService;

  /// Internal connection state flag.
  ///
  /// This tracks whether we have an active SSH connection.
  /// It's used to:
  /// - Determine if action buttons should be enabled in the UI
  /// - Decide whether to re-emit LgConnected after action success
  /// - Prevent actions when disconnected
  bool _isConnected = false;

  /// Creates the cubit with an injected SSH service.
  ///
  /// Starts in LgInitial state - no connection attempted yet.
  LgCubit(this._sshService) : super(LgInitial());

  /// Helper method to re-emit LgConnected state after successful actions.
  ///
  /// After an action completes (successfully or with error), we want to
  /// return to the LgConnected state so the UI remains in "connected" mode
  /// with buttons enabled. This helper avoids repeating the check everywhere.
  void _emitConnected() {
    if (_isConnected) emit(LgConnected());
  }

  /// Establishes SSH connection to the LG master machine.
  ///
  /// This method:
  /// 1. Emits LgConnecting to show loading UI
  /// 2. Calls SshService.connect() which reads saved credentials
  /// 3. On success: sets _isConnected = true, emits LgConnected
  /// 4. On failure: sets _isConnected = false, emits LgError
  ///
  /// The connection parameters (IP, port, username, password) are read
  /// from SharedPreferences which were saved by the HomeScreen connection form.
  Future<void> connectToLg() async {
    emit(LgConnecting());
    final success = await _sshService.connect();
    if (success) {
      _isConnected = true;
      emit(LgConnected());
    } else {
      _isConnected = false;
      emit(LgError(message: 'Failed to connect to LG'));
    }
  }

  /// Sends the Liquid Galaxy logo to the left screen (slave 3).
  ///
  /// This action:
  /// 1. Generates KML with the LG logo image URL
  /// 2. Sends it via SSH to the master machine
  /// 3. Updates kmls_3.txt so slave 3 displays it
  /// 4. Restarts Apache to apply changes
  ///
  /// The logo appears only on the leftmost screen in a 3-screen LG setup.
  /// Emits LgActionSuccess on completion, then returns to LgConnected.
  Future<void> sendLogos() async {
    final logoKml = KMLMaker.screenOverlayImage(
      'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEgXmdNgBTXup6bdWew5RzgCmC9pPb7rK487CpiscWB2S8OlhwFHmeeACHIIjx4B5-Iv-t95mNUx0JhB_oATG3-Tq1gs8Uj0-Xb9Njye6rHtKKsnJQJlzZqJxMDnj_2TXX3eA5x6VSgc8aw/s320-rw/LOGO+LIQUID+GALAXY-sq1000-+OKnoline.png',
      0.8,
    );
    await _sshService.sendLogo(logoKml);
    emit(LgActionSuccess(message: "Logo Sent to LEFT Screen (lg3)!"));
    _emitConnected();
  }

  /// Sends a 3D pyramid KML and flies to Cairo.
  ///
  /// This action:
  /// 1. Generates a colorful 3D pyramid KML near Giza
  /// 2. Sends the KML to the LG master
  /// 3. Flies the camera to Cairo with a tilted view (45° tilt, 1000m range)
  ///
  /// The pyramid demonstrates 3D KML capabilities with 4 colored faces
  /// meeting at a 300m high peak above the ground.
  Future<void> sendPyramid() async {
    final pyramidKml = KMLMaker.generatePyramid();
    await _sshService.sendKML(pyramidKml, "pyramid.kml");
    await _sshService.flyTo(
      AppConstants.cairoLat,
      AppConstants.cairoLong,
      1000, // 1000m range = closer view
      45, // 45° tilt = angled view
      0, // 0° heading = facing north
    );
    emit(LgActionSuccess(message: "Pyramid Sent & View Updated!"));
    _emitConnected();
  }

  /// Flies the camera to Cairo with a top-down view.
  ///
  /// This is a "home" button that returns the view to the Giza Pyramids
  /// area with a straight-down perspective (0° tilt) from 5000m altitude.
  ///
  /// Useful for resetting the view after exploring other locations.
  Future<void> flyToCairo() async {
    await _sshService.flyTo(
      AppConstants.cairoLat,
      AppConstants.cairoLong,
      5000, // 5000m range = wider view
      0, // 0° tilt = top-down
      0, // 0° heading = north
    );
    emit(LgActionSuccess(message: "Flying to Cairo..."));
    _emitConnected();
  }

  /// Clears all KMLs from the LG display.
  ///
  /// This empties the kmls.txt index file, causing Google Earth to
  /// unload all overlays including the pyramid. The view returns to
  /// the base Google Earth globe without any custom content.
  ///
  /// Note: This does NOT clear the logo on slave 3 (use cleanLogos for that).
  Future<void> cleanKml() async {
    await _sshService.cleanSlaves();
    emit(LgActionSuccess(message: "KMLs Cleaned"));
    _emitConnected();
  }

  /// Removes the logo from the left screen (slave 3).
  ///
  /// This specifically targets the logo KML (slave_3.kml) and removes
  /// it from kmls_3.txt. Other KMLs like the pyramid are preserved.
  ///
  /// This allows cleaning just the logo while keeping other content.
  Future<void> cleanLogos() async {
    final success = await _sshService.cleanLogo();
    if (success) {
      emit(LgActionSuccess(message: "Logo Cleaned from LEFT Screen (lg3)"));
    } else {
      emit(LgError(message: "Failed to clean logo from lg3"));
    }
    _emitConnected();
  }
}
