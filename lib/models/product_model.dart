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

  /// Resolves image path against backend API base URL
  String get resolvedImageUrl => ApiConstants.resolveImageUrl(imageUrl);

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
    id: (json["id"] as num?)?.toInt() ?? 0,
    categoryId: (json["categoryId"] as num?)?.toInt(),
    categoryName: json["categoryName"] as String?,
    name: json["name"] as String? ?? "",
    description: json["description"] as String?,
    price: (json["price"] as num?)?.toDouble() ?? 0.0,
    stockQuantity: (json["stockQuantity"] as num?)?.toInt() ?? 0,
    imageUrl: json["imageUrl"] as String?,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "categoryId": categoryId,
    "categoryName": categoryName,
    "name": name,
    "description": description,
    "price": price,
    "stockQuantity": stockQuantity,
    "imageUrl": imageUrl,
  };
}