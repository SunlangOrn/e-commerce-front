import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../../models/user_model.dart';
import 'api_client.dart';

class UploadService {
  final _dio = ApiClient.instance.dio;

  Future<UserModel> uploadProfileImage(String filePath) async {
    final formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(filePath),
    });
    final res = await _dio.post(
      ApiConstants.uploadProfileImage,
      data: formData,
      options: Options(contentType: "multipart/form-data"),
    );
    return UserModel.fromJson(res.data["data"]);
  }
}