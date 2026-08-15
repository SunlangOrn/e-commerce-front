class CartItemModel {
  final int id;
  final int productId;
  final String productName;
  final String? productImage;
  final double price;
  final int quantity;
  final double subtotal;

  CartItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    this.productImage,
    required this.price,
    required this.quantity,
    required this.subtotal,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final parsedPrice = (json["price"] as num?)?.toDouble() ?? 0.0;
    final parsedQty = json["quantity"] as int? ?? 0;
    final parsedSubtotal =
        (json["subtotal"] as num?)?.toDouble() ?? (parsedPrice * parsedQty);

    return CartItemModel(
      id: json["id"] ?? 0,
      productId: json["productId"] ?? 0,
      productName: json["productName"] ?? "",
      productImage: json["productImage"],
      price: parsedPrice,
      quantity: parsedQty,
      subtotal: parsedSubtotal,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "productId": productId,
    "productName": productName,
    "productImage": productImage,
    "price": price,
    "quantity": quantity,
    "subtotal": subtotal,
  };
}