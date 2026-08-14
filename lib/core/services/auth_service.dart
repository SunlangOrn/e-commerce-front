import '../constants/api_constants.dart';
import '../../models/user_model.dart';
import '../../models/token_model.dart';
import 'api_client.dart';

class AuthService {
  final _dio = ApiClient.instance.dio;

  Future<TokenModel> signup({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    final res = await _dio.post(ApiConstants.signup, data: {
      "name": name,
      "email": email,
      "password": password,
      if (phone != null) "phone": phone,
    });
    return TokenModel.fromJson(res.data["data"]);
  }

  Future<TokenModel> signin({
    required String email,
    required String password,
  }) async {
    final res = await _dio.post(ApiConstants.signin, data: {
      "email": email,
      "password": password,
    });
    return TokenModel.fromJson(res.data["data"]);
  }

  Future<void> logout(String refreshToken) async {
    await _dio.post(ApiConstants.logout, data: {"refreshToken": refreshToken});
  }

  Future<UserModel> me() async {
    final res = await _dio.get(ApiConstants.me);
    return UserModel.fromJson(res.data["data"]);
  }

  Future<UserModel> updateProfile({
    required String name,
    String? phone,
  }) async {
    final res = await _dio.put(ApiConstants.updateProfile, data: {
      "name": name,
      if (phone != null) "phone": phone,
    });
    return UserModel.fromJson(res.data["data"]);
  }
}