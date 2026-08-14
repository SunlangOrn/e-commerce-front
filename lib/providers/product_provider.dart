import 'package:flutter/material.dart';
import '../core/services/product_service.dart';
import '../models/product_model.dart';

class ProductProvider extends ChangeNotifier {
  final _productService = ProductService();

  List<ProductModel> products = [];
  ProductModel? selectedProduct;
  bool isLoading = false;
  String? errorMessage;

  int currentPage = 0;
  int totalPages = 1;
  String keyword = "";

  Future<void> fetchProducts({int page = 0, String? keyword}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final result = await _productService.browse(
        page: page,
        size: 20,
        keyword: keyword,
      );
      products = result.products;
      currentPage = result.page;
      totalPages = result.totalPages;
    } catch (_) {
      errorMessage = "Failed to load products";
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> fetchProductDetail(int id) async {
    isLoading = true;
    notifyListeners();
    try {
      selectedProduct = await _productService.getById(id);
    } catch (_) {
      errorMessage = "Failed to load product";
    }
    isLoading = false;
    notifyListeners();
  }
}