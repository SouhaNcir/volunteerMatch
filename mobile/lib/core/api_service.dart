import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

String get apiBaseUrl {
  if (kIsWeb) return 'http://127.0.0.1:8000/api';
  if (defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:8000/api'; // émulateur Android
  }
  return 'http://127.0.0.1:8000/api';
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

String parseError(Object e) {
  if (e is DioException) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return 'Impossible de joindre le serveur. Vérifiez que Django est lancé.';
    }
    final data = e.response?.data;
    if (data is Map && data.isNotEmpty) {
      if (data['detail'] != null) return data['detail'].toString();
      final first = data.values.first;
      return (first is List && first.isNotEmpty ? first.first : first)
          .toString();
    }
  }
  return 'Une erreur est survenue. Réessayez.';
}

class ApiService {
  ApiService._() {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'access');
        if (token != null) options.headers['Authorization'] = 'Bearer $token';
        handler.next(options);
      },
      onError: (e, handler) async {
        final retried = e.requestOptions.extra['retried'] == true;
        if (e.response?.statusCode == 401 && !retried && await _refresh()) {
          final opts = e.requestOptions..extra['retried'] = true;
          opts.headers['Authorization'] =
          'Bearer ${await _storage.read(key: 'access')}';
          try {
            return handler.resolve(await dio.fetch(opts));
          } on DioException catch (err) {
            return handler.next(err);
          }
        }
        handler.next(e);
      },
    ));
  }

  static final ApiService instance = ApiService._();

  final _storage = const FlutterSecureStorage();
  final Dio dio = Dio(BaseOptions(
    baseUrl: apiBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
    headers: {'Accept': 'application/json'},
  ));

  Future<void> saveTokens(String access, String refresh) async {
    await _storage.write(key: 'access', value: access);
    await _storage.write(key: 'refresh', value: refresh);
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: 'access');
    await _storage.delete(key: 'refresh');
  }

  Future<bool> hasToken() async => await _storage.read(key: 'access') != null;

  Future<bool> _refresh() async {
    final refresh = await _storage.read(key: 'refresh');
    if (refresh == null) return false;
    try {
      final res = await Dio(BaseOptions(baseUrl: apiBaseUrl))
          .post('/auth/refresh/', data: {'refresh': refresh});
      await _storage.write(key: 'access', value: res.data['access']);
      if (res.data['refresh'] != null) {
        await _storage.write(key: 'refresh', value: res.data['refresh']);
      }
      return true;
    } catch (_) {
      await clearTokens();
      return false;
    }
  }
}