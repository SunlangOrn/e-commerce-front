import '../constants/api_constants.dart';
import '../../models/payment_model.dart';
import 'api_client.dart';

class PaymentService {
  final _dio = ApiClient.instance.dio;

  Future<AbaPayWayResponseModel> createAbaKhqr(int orderId) async {
    final res = await _dio.post(ApiConstants.createAbaKhqr(orderId));
    return AbaPayWayResponseModel.fromJson(res.data["data"]);
  }

  Future<AbaPayWayResponseModel> checkAbaKhqr(int orderId) async {
    final res = await _dio.get(ApiConstants.checkAbaKhqr(orderId));
    return AbaPayWayResponseModel.fromJson(res.data["data"]);
  }
}