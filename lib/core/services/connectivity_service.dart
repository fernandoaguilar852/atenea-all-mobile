import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Estados de conectividad
enum NetworkStatus {
  online,
  offline,
  slow,
}

/// Servicio para monitorear la conectividad
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final StreamController<NetworkStatus> _statusController =
      StreamController<NetworkStatus>.broadcast();

  Stream<NetworkStatus> get statusStream => _statusController.stream;
  NetworkStatus _currentStatus = NetworkStatus.online;

  ConnectivityService() {
    _init();
  }

  void _init() {
    // Escuchar cambios en la conectividad
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      _updateStatus(results);
    });

    // Verificar estado inicial
    _checkInitialStatus();
  }

  Future<void> _checkInitialStatus() async {
    final results = await _connectivity.checkConnectivity();
    _updateStatus(results);
  }

  void _updateStatus(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.none)) {
      _currentStatus = NetworkStatus.offline;
    } else if (results.contains(ConnectivityResult.wifi) ||
               results.contains(ConnectivityResult.ethernet)) {
      _currentStatus = NetworkStatus.online;
    } else if (results.contains(ConnectivityResult.mobile)) {
      // Considerar móvil como potencialmente lenta
      _currentStatus = NetworkStatus.slow;
    } else {
      _currentStatus = NetworkStatus.online;
    }

    _statusController.add(_currentStatus);
  }

  NetworkStatus get currentStatus => _currentStatus;

  bool get isOnline => _currentStatus != NetworkStatus.offline;
  bool get isOffline => _currentStatus == NetworkStatus.offline;
  bool get isSlow => _currentStatus == NetworkStatus.slow;

  void dispose() {
    _statusController.close();
  }
}

/// Provider para el servicio de conectividad
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Provider para el estado de red actual
final networkStatusProvider = StreamProvider<NetworkStatus>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.statusStream;
});
