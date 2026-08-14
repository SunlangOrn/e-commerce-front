import '../constants/api_constants.dart';
import '../../models/product_model.dart';
import 'api_client.dart';

class ProductPage {
  final List<ProductModel> products;
  final int page;
  final int totalPages;
  final int totalElements;

  ProductPage({
    required this.products,
    required this.page,
    required this.totalPages,
    required this.totalElements,
  });
}

class ProductService {
  final _dio = ApiClient.instance.dio;

  Future<ProductPage> browse({
    int? page,
    int? size,
    int? categoryId,
    String? keyword,
  }) async {
    final res = await _dio.get(ApiConstants.products, queryParameters: {
      if (page != null) "page": page,
      if (size != null) "size": size,
      if (categoryId != null) "categoryId": categoryId,
      if (keyword != null && keyword.isNotEmpty) "keyword": keyword,
    });

    final list = res.data["data"] as List<dynamic>;
    final paging = res.data["paging"];

    return ProductPage(
      products: list.map((e) => ProductModel.fromJson(e)).toList(),
      page: paging?["page"] ?? 0,
      totalPages: paging?["totalPages"] ?? 1,
      totalElements: paging?["total"] ?? list.length,
    );
  }

  Future<ProductModel> getById(int id) async {
    final res = await _dio.get(ApiConstants.productById(id));
    return ProductModel.fromJson(res.data["data"]);
  }
}