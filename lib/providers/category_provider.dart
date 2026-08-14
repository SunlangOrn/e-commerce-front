import 'package:flutter/material.dart';
import '../core/services/category_service.dart';
import '../models/category_model.dart';

class CategoryProvider extends ChangeNotifier {
  final _categoryService = CategoryService();

  List<CategoryModel> categories = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> fetchCategories() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      categories = await _categoryService.getCategories();
    } catch (_) {
      errorMessage = "Failed to load categories";
    }
    isLoading = false;
    notifyListeners();
  }
}