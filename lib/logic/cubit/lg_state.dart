/// Base class for all LG (Liquid Galaxy) connection states.
///
/// The LgCubit emits these states to notify the UI about connection status
/// and action results. The UI uses BlocListener and BlocBuilder to react
/// to these state changes (showing snackbars, enabling/disabling buttons, etc.)
abstract class LgState {}

/// Initial state before any connection attempt.
///
/// This is the starting state when the app launches. The UI shows
/// connection form fields and disabled action buttons in this state.
class LgInitial extends LgState {}

/// Connection in progress state.
///
/// Emitted when connectToLg() is called and SSH connection is being
/// established. The UI shows a loading snackbar to indicate that
/// the app is trying to connect to the LG master machine.
class LgConnecting extends LgState {}

/// Successfully connected to LG.
///
/// Emitted when SSH connection is established successfully.
/// The UI enables all action buttons (Send Logo, Send Pyramid, etc.)
/// and shows a success snackbar. This state persists until disconnect
/// or connection loss.
class LgConnected extends LgState {}

/// Disconnected from LG.
///
/// Currently not actively used in the app but available for future
/// use when implementing explicit disconnect functionality or handling
/// connection timeouts.
class LgDisconnected extends LgState {}

/// Error state for connection or action failures.
///
/// Emitted when:
/// - SSH connection fails (wrong IP, port, credentials)
/// - Network is unreachable
/// - SSH command execution fails
///
/// The UI displays the error message in a red snackbar to alert the user.
class LgError extends LgState {
  /// Human-readable error message to display to the user
  final String message;

  LgError({required this.message});
}

/// Success state for completed actions.
///
/// Emitted when an action (send logo, send pyramid, clean KML, etc.)
/// completes successfully. The UI shows a green snackbar with the
/// success message, then returns to LgConnected state.
///
/// This provides user feedback that their button press had an effect.
class LgActionSuccess extends LgState {
  /// Success message describing what was accomplished
  final String message;

  LgActionSuccess({required this.message});
}
