import 'package:flutter/material.dart';
import '../core/services/auth_service.dart';
import '../core/services/storage_service.dart';
import '../core/services/upload_service.dart';
import '../models/user_model.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final _authService = AuthService();
  final _uploadService = UploadService();

  AuthStatus status = AuthStatus.unknown;
  UserModel? currentUser;
  String? errorMessage;
  bool isLoading = false;

  /// Checks stored tokens and retrieves profile details on app launch
  Future<void> checkAuthStatus() async {
    final token = await StorageService.instance.getAccessToken();
    if (token == null) {
      status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }
    try {
      currentUser = await _authService.me();
      status = AuthStatus.authenticated;
    } catch (_) {
      status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> signup({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) =>
      _run(() async {
        final tokens = await _authService.signup(
          name: name,
          email: email,
          password: password,
          phone: phone,
        );
        await StorageService.instance.saveTokens(
          accessToken: tokens.accessToken,
          refreshToken: tokens.refreshToken,
        );
        currentUser = await _authService.me();
        status = AuthStatus.authenticated;
      });

  Future<bool> signin({required String email, required String password}) =>
      _run(() async {
        final tokens =
        await _authService.signin(email: email, password: password);
        await StorageService.instance.saveTokens(
          accessToken: tokens.accessToken,
          refreshToken: tokens.refreshToken,
        );
        currentUser = await _authService.me();
        status = AuthStatus.authenticated;
      });

  Future<bool> updateProfile({required String name, String? phone}) =>
      _run(() async {
        currentUser =
        await _authService.updateProfile(name: name, phone: phone);
      });

  Future<bool> uploadProfileImage(String filePath) => _run(() async {
    currentUser = await _uploadService.uploadProfileImage(filePath);
  });

  Future<void> logout() async {
    final refreshToken = await StorageService.instance.getRefreshToken();
    try {
      if (refreshToken != null) await _authService.logout(refreshToken);
    } catch (_) {
      // ignore network errors on logout
    }
    await StorageService.instance.clear();
    currentUser = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<bool> _run(Future<void> Function() action) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await action();
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      isLoading = false;
      errorMessage = _extractError(e);
      notifyListeners();
      return false;
    }
  }

  String _extractError(Object e) {
    debugPrint("❌ [AuthProvider Error]: $e");
    try {
      final response = (e as dynamic).response;

      if (response != null) {
        debugPrint("❌ [Response Status]: ${response.statusCode}");
        debugPrint("❌ [Response Data]: ${response.data}");

        final data = response.data;
        if (data is Map<String, dynamic> && data["message"] != null) {
          return data["message"].toString();
        }
        return "Server Error (${response.statusCode})";
      }
    } catch (_) {}

    return "Cannot connect to server (192.168.1.3:16800). Check Wi-Fi & Firewall.";
  }
}