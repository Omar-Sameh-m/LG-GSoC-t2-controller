
abstract class LgState {}

class LgInitial extends LgState {}

class LgConnecting extends LgState {}

class LgConnected extends LgState {}

class LgDisconnected extends LgState {}

class LgError extends LgState {
  final String message;

  LgError({required this.message});
}

class LgActionSuccess extends LgState {
  final String message;

  LgActionSuccess( {required this.message});
}
