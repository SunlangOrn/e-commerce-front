import '../constants/api_constants.dart';
import '../../models/cart_model.dart';
import 'api_client.dart';

class CartService {
  final _dio = ApiClient.instance.dio;

  Future<CartModel> getMyCart() async {
    final res = await _dio.get(ApiConstants.myCart);
    return CartModel.fromJson(res.data["data"]);
  }

  Future<CartModel> addItem({required int productId, required int quantity}) async {
    final res = await _dio.post(ApiConstants.cartItems, data: {
      "productId": productId,
      "quantity": quantity,
    });
    return CartModel.fromJson(res.data["data"]);
  }

  Future<CartModel> updateItem({required int itemId, required int quantity}) async {
    final res = await _dio.patch(
      ApiConstants.cartItemById(itemId),
      queryParameters: {"quantity": quantity},
    );
    return CartModel.fromJson(res.data["data"]);
  }

  Future<CartModel> removeItem(int itemId) async {
    final res = await _dio.delete(ApiConstants.cartItemById(itemId));
    return CartModel.fromJson(res.data["data"]);
  }

  Future<void> clearCart() async {
    await _dio.delete(ApiConstants.clearCart);
  }
}