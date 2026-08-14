import '../core/constants/api_constants.dart';

class ProductModel {
  final int id;
  final int? categoryId;
  final String? categoryName;
  final String name;
  final String? description;
  final double price;
  final int stockQuantity;
  final String? imageUrl;

  ProductModel({
    required this.id,
    this.categoryId,
    this.categoryName,
    required this.name,
    this.description,
    required this.price,
    required this.stockQuantity,
    this.imageUrl,
  });

  /// Full, loadable image URL (host + relative path from backend).
  String get resolvedImageUrl => ApiConstants.resolveImageUrl(imageUrl);

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
    id: json["id"],
    categoryId: json["categoryId"],
    categoryName: json["categoryName"],
    name: json["name"] ?? "",
    description: json["description"],
    price: (json["price"] as num?)?.toDouble() ?? 0.0,
    stockQuantity: json["stockQuantity"] ?? 0,
    imageUrl: json["imageUrl"],
  );
}