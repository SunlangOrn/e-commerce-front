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
  int totalElements = 0;

  int? selectedCategoryId;
  String keyword = "";

  /// Fetch products from Spring Boot API via Dio
  Future<void> fetchProducts({
    int page = 0,
    int? categoryId,
    String? keyword,
  }) async {
    // Keep track of active category selection
    if (categoryId != selectedCategoryId) {
      selectedCategoryId = categoryId;
    }
    if (keyword != null) {
      this.keyword = keyword;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _productService.browse(
        page: page,
        size: 20,
        categoryId: selectedCategoryId,
        keyword: this.keyword,
      );

      products = result.products;
      currentPage = result.page;
      totalPages = result.totalPages;
      totalElements = result.totalElements;
    } catch (e) {
      errorMessage = "Failed to load products";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch detail page product
  Future<void> fetchProductDetail(int id) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      selectedProduct = await _productService.getById(id);
    } catch (_) {
      errorMessage = "Failed to load product details";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Clear all search & category filters
  void clearFilters() {
    selectedCategoryId = null;
    keyword = "";
    fetchProducts(page: 0);
  }
}