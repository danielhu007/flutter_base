import 'package:flutter_base/network/api_service.dart';
import 'package:flutter_base/network/connectivity_checker.dart';
import 'package:flutter_base/utils/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  final apiService = ApiService();
  const apiUrl = 'https://jsonplaceholder.typicode.com'; // 示例API URL
  apiService.init(baseUrl: apiUrl);
  apiService.enableCache();
  return apiService;
});

final connectivityCheckerProvider = Provider<ConnectivityChecker>((ref) {
  final connectivityChecker = ConnectivityChecker();
  connectivityChecker.init();
  ref.onDispose(connectivityChecker.dispose);
  return connectivityChecker;
});

final networkStatusProvider =
    StateNotifierProvider<NetworkStatusNotifier, bool>((ref) {
  final connectivityChecker = ref.watch(connectivityCheckerProvider);
  return NetworkStatusNotifier(connectivityChecker.isOnline);
});

class NetworkStatusNotifier extends StateNotifier<bool> {
  NetworkStatusNotifier(super.initialState);

  void update(bool isOnline) {
    state = isOnline;
  }
}

class NetworkService {
  static final log = getLogger(NetworkService);

  static void initialize() {
    log.i('NetworkService initialized');
  }
}
