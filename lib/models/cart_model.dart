import 'cart_item_model.dart';

class CartModel {
  final int id;
  final List<CartItemModel> items;
  final double total;

  CartModel({
    required this.id,
    required this.items,
    required this.total,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) => CartModel(
    id: json["id"] ?? 0,
    items: (json["items"] as List<dynamic>? ?? [])
        .map((e) => CartItemModel.fromJson(e))
        .toList(),
    total: (json["total"] as num?)?.toDouble() ?? 0.0,
  );

  factory CartModel.empty() => CartModel(id: 0, items: [], total: 0.0);
}