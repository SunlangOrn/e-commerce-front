import 'payment_model.dart';

class OrderItemModel {
  final int id;
  final int productId;
  final String productName;
  final String? productImage;
  final int quantity;
  final double price;
  final double subtotal;
  final String? currency;

  OrderItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    this.productImage,
    required this.quantity,
    required this.price,
    required this.subtotal,
    this.currency,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) => OrderItemModel(
    id: json["id"],
    productId: json["productId"],
    productName: json["productName"] ?? "",
    productImage: json["productImage"],
    quantity: json["quantity"] ?? 0,
    price: (json["price"] as num?)?.toDouble() ?? 0.0,
    subtotal: (json["subtotal"] as num?)?.toDouble() ?? 0.0,
    currency: json["currency"],
  );
}

class OrderModel {
  final int id;
  final String orderNumber;
  final double totalAmount;
  final String orderStatus;
  final String paymentStatus;
  final String paymentMethod;
  final int totalItems;
  final List<OrderItemModel> items;
  final String createdAt;
  final AbaPayWayResponseModel? abaPayWayResponse;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.totalAmount,
    required this.orderStatus,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.totalItems,
    required this.items,
    required this.createdAt,
    this.abaPayWayResponse,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
    id: json["id"],
    orderNumber: json["orderNumber"] ?? "",
    totalAmount: (json["totalAmount"] as num?)?.toDouble() ?? 0.0,
    orderStatus: json["orderStatus"] ?? "",
    paymentStatus: json["paymentStatus"] ?? "",
    paymentMethod: json["paymentMethod"] ?? "",
    totalItems: json["totalItems"] ?? 0,
    items: (json["items"] as List<dynamic>? ?? [])
        .map((e) => OrderItemModel.fromJson(e))
        .toList(),
    createdAt: json["createdAt"] ?? "",
    abaPayWayResponse: json["abaPayWayResponse"] != null
        ? AbaPayWayResponseModel.fromJson(json["abaPayWayResponse"])
        : null,
  );
}