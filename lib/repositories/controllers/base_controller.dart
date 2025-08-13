import 'package:dio/dio.dart';
import 'package:flutter_base/network/api_service.dart';
import 'package:flutter_base/network/network_service_provider.dart';
import 'package:flutter_base/utils/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BaseController {
  final _log = getLogger(BaseController);
  final String baseUrl;
  late final ApiService _apiService;
  final Ref? ref;

  BaseController({required this.baseUrl, this.ref}) {
    if (ref != null) {
      _apiService = ref!.read(apiServiceProvider);
    } else {
      _apiService = ApiService();
      _apiService.init(baseUrl: baseUrl);
      _apiService.enableCache();
    }
  }

  Future<dynamic> getJson(String path) async {
    _log.t('GET: $path');

    final response = await _apiService.dio.get(path);
    return _getResponseData(response);
  }

  Future<List<dynamic>> getJsonList(String path) async {
    _log.t('GET: $path');

    final response = await _apiService.dio.get(path);
    return await _getResponseData(response) as List<dynamic>;
  }

  Future<dynamic> postJson(String path, dynamic data) async {
    _log.t('POST: $path');

    final response = await _apiService.dio.post(path, data: data);
    return _getResponseData(response);
  }

  Future<bool> putJson(String path, {dynamic data}) async {
    _log.t('PUT: $path');

    final response = await _apiService.dio.put(path, data: data);
    return _isRequestOK(response);
  }

  Future<dynamic> putJsonWithResponse(String path, {dynamic data}) async {
    _log.t('PUT: $path');

    final response = await _apiService.dio.put(path, data: data);
    return _getResponseData(response);
  }

  Future<bool> deleteJson(String path, {String? data}) async {
    _log.t('DELETE: $path');

    final response = await _apiService.dio.delete(path, data: data);
    return _isRequestOK(response);
  }

  Future<dynamic> _getResponseData(Response response) async {
    _log.t(response.requestOptions.uri);
    _log.t(response.requestOptions.data);
    _log.t(response.data);

    try {
      if (response.statusCode == 200) {
        _log.t('Request OK with data!');
        return response.data;
      } else {
        _log.d(response.statusCode);
        return Future<dynamic>.error({});
      }
    } catch (err) {
      _log.e(err);
      return Future<dynamic>.error(err);
    }
  }

  Future<bool> _isRequestOK(Response response) async {
    try {
      if (response.statusCode == 200) {
        _log.t('Request OK with data!');
        return true;
      } else {
        _log.d(response.statusCode);
        return Future<bool>.error({});
      }
    } catch (err) {
      _log.e(err);
      return Future<bool>.error(err);
    }
  }
}
