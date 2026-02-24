import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Service to check network connectivity status
class NetworkInfo {
  final Connectivity _connectivity;

  NetworkInfo({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  /// Checks if device has an active internet connection
  /// Returns true if connected, false otherwise
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return _hasConnection(result);
  }

  /// Listens to connectivity changes
  /// Emits true when connected, false when disconnected
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged
        .map((result) => _hasConnection(result));
  }

  /// Helper method to check if connection result indicates connectivity
  bool _hasConnection(List<ConnectivityResult> result) {
    return result.isNotEmpty && !result.contains(ConnectivityResult.none);
  }

  /// Checks if device is connected to WiFi
  Future<bool> get isWiFi async {
    final result = await _connectivity.checkConnectivity();
    return result.contains(ConnectivityResult.wifi);
  }

  /// Checks if device is connected via mobile data
  Future<bool> get isMobileData async {
    final result = await _connectivity.checkConnectivity();
    return result.contains(ConnectivityResult.mobile);
  }
}

/// Riverpod provider for NetworkInfo singleton
final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfo();
});

/// Stream provider for connectivity status changes
/// Emits true when connected, false when disconnected
final connectivityProvider = StreamProvider<bool>((ref) {
  final networkInfo = ref.watch(networkInfoProvider);
  return networkInfo.onConnectivityChanged;
});

/// Future provider for current connectivity status
/// Provides a one-time check of the current connectivity state
final currentConnectivityProvider = FutureProvider<bool>((ref) {
  final networkInfo = ref.watch(networkInfoProvider);
  return networkInfo.isConnected;
});

/// Future provider to check if connected to WiFi
final isWiFiProvider = FutureProvider<bool>((ref) {
  final networkInfo = ref.watch(networkInfoProvider);
  return networkInfo.isWiFi;
});

/// Future provider to check if connected via mobile data
final isMobileDataProvider = FutureProvider<bool>((ref) {
  final networkInfo = ref.watch(networkInfoProvider);
  return networkInfo.isMobileData;
});
