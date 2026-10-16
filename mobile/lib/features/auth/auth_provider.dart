import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_service.dart';
import '../../models/user.dart';

enum AuthStatus { checking, signedOut, signedIn }

class AuthState {
  final AuthStatus status;
  final AppUser? user;
  const AuthState(this.status, [this.user]);
}

final authProvider =
NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

class AuthNotifier extends Notifier<AuthState> {
  final _api = ApiService.instance;

  @override
  AuthState build() {
    _restore();
    return const AuthState(AuthStatus.checking);
  }

  /// Au démarrage : reprend la session si un token existe.
  Future<void> _restore() async {
    if (!await _api.hasToken()) {
      state = const AuthState(AuthStatus.signedOut);
      return;
    }
    try {
      final res = await _api.dio.get('/users/me/');
      state = AuthState(AuthStatus.signedIn, AppUser.fromJson(res.data));
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) await _api.clearTokens();
      state = const AuthState(AuthStatus.signedOut);
    }
  }

  Future<void> login(String email, String password) async {
    try {
      final res = await _api.dio.post('/auth/login/',
          data: {'email': email.trim(), 'password': password});
      await _api.saveTokens(res.data['access'], res.data['refresh']);
      state = AuthState(AuthStatus.signedIn, AppUser.fromJson(res.data['user']));
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw ApiException('E-mail ou mot de passe incorrect.');
      }
      throw ApiException(parseError(e));
    }
  }

  Future<void> register(Map<String, dynamic> data) async {
    try {
      await _api.dio.post('/auth/register/', data: data);
    } on DioException catch (e) {
      throw ApiException(parseError(e));
    }
    await login(data['email'], data['password']);
  }

  /// Recharge le profil (ex. : une association vient d'être approuvée).
  Future<void> refresh() async {
    try {
      final res = await _api.dio.get('/users/me/');
      state = AuthState(AuthStatus.signedIn, AppUser.fromJson(res.data));
    } on DioException catch (e) {
      throw ApiException(parseError(e));
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      final res = await _api.dio.patch('/users/me/', data: data);
      state = AuthState(AuthStatus.signedIn, AppUser.fromJson(res.data));
    } on DioException catch (e) {
      throw ApiException(parseError(e));
    }
  }

  Future<void> logout() async {
    await _api.clearTokens();
    state = const AuthState(AuthStatus.signedOut);
  }
}