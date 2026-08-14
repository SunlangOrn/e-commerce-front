import '../constants/api_constants.dart';
import '../../models/order_model.dart';
import 'api_client.dart';

class OrderService {
  final _dio = ApiClient.instance.dio;

  /// paymentMethod: "ABA_PAYWAY_KHQR" or "CASH_ON_DELIVERY"
  Future<OrderModel> checkout({
    required int addressId,
    required String paymentMethod,
    String? note,
  }) async {
    final res = await _dio.post(ApiConstants.checkout, data: {
      "addressId": addressId,
      "paymentMethod": paymentMethod,
      if (note != null) "note": note,
    });
    return OrderModel.fromJson(res.data["data"]);
  }

  Future<OrderModel> getById(int id) async {
    final res = await _dio.get(ApiConstants.orderById(id));
    return OrderModel.fromJson(res.data["data"]);
  }

  Future<List<OrderModel>> list() async {
    final res = await _dio.get(ApiConstants.orders);
    final data = res.data["data"];
    final content = (data is Map && data["content"] != null)
        ? data["content"] as List<dynamic>
        : (data as List<dynamic>);
    return content.map((e) => OrderModel.fromJson(e)).toList();
  }



  Future<OrderModel> cancel(int id) async {
    final res = await _dio.patch(ApiConstants.orderCancel(id));
    return OrderModel.fromJson(res.data["data"]);
  }
}