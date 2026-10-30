import 'dart:async';

/// Event bus global para eventos de autenticación
class AuthEvents {
  static final AuthEvents _instance = AuthEvents._internal();
  factory AuthEvents() => _instance;
  AuthEvents._internal();

  final _unauthorizedController = StreamController<void>.broadcast();

  Stream<void> get onUnauthorized => _unauthorizedController.stream;

  void notifyUnauthorized() {
    _unauthorizedController.add(null);
  }

  void dispose() {
    _unauthorizedController.close();
  }
}
