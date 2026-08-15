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
    id: json["id"] ?? 0,
    productId: json["productId"] ?? 0,
    productName: json["productName"] ?? "",
    productImage: json["productImage"],
    quantity: json["quantity"] ?? 0,
    price: (json["price"] as num?)?.toDouble() ?? 0.0,
    subtotal: (json["subtotal"] as num?)?.toDouble() ?? 0.0,
    currency: json["currency"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "productId": productId,
    "productName": productName,
    "productImage": productImage,
    "quantity": quantity,
    "price": price,
    "subtotal": subtotal,
    "currency": currency,
  };
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
  final String? paidAt; // ADDED
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
    this.paidAt, // ADDED
    this.abaPayWayResponse,
  });

  // Backward compatibility alias for UI checks
  String get status => orderStatus;

  // Convenience getter to check if order/payment completed
  bool get isPaid =>
      paymentStatus.toUpperCase() == "SUCCESS" ||
          paymentStatus.toUpperCase() == "PAID" ||
          orderStatus.toUpperCase() == "COMPLETED" ||
          orderStatus.toUpperCase() == "PROCESSING" ||
          paymentMethod == "CASH_ON_DELIVERY";

  /// Create a updated copy of OrderModel
  OrderModel copyWith({
    int? id,
    String? orderNumber,
    double? totalAmount,
    String? orderStatus,
    String? paymentStatus,
    String? paymentMethod,
    int? totalItems,
    List<OrderItemModel>? items,
    String? createdAt,
    String? paidAt, // ADDED
    AbaPayWayResponseModel? abaPayWayResponse,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      totalAmount: totalAmount ?? this.totalAmount,
      orderStatus: orderStatus ?? this.orderStatus,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      totalItems: totalItems ?? this.totalItems,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      paidAt: paidAt ?? this.paidAt, // ADDED
      abaPayWayResponse: abaPayWayResponse ?? this.abaPayWayResponse,
    );
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
    id: json["id"] ?? 0,
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
    paidAt: json["paidAt"], // ADDED
    abaPayWayResponse: json["abaPayWayResponse"] != null
        ? AbaPayWayResponseModel.fromJson(json["abaPayWayResponse"])
        : null,
  );
}