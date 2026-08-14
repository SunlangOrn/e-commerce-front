class CartItemModel {
  final int id;
  final int productId;
  final String productName;
  final double price;
  final int quantity;
  final double subtotal;

  CartItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.subtotal,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) => CartItemModel(
    id: json["id"],
    productId: json["productId"],
    productName: json["productName"] ?? "",
    price: (json["price"] as num?)?.toDouble() ?? 0.0,
    quantity: json["quantity"] ?? 0,
    subtotal: (json["subtotal"] as num?)?.toDouble() ?? 0.0,
  );
}