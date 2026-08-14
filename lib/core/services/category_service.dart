import '../constants/api_constants.dart';
import '../../models/category_model.dart';
import 'package:flutter/material.dart';
import 'api_client.dart';

class CategoryService extends ChangeNotifier  {
  final _dio = ApiClient.instance.dio;

  Future<List<CategoryModel>> getCategories() async {
    final res = await _dio.get(ApiConstants.categories);
    final list = res.data["data"] as List<dynamic>;
    return list.map((e) => CategoryModel.fromJson(e)).toList();
  }

  Future<CategoryModel> getById(int id) async {
    final res = await _dio.get(ApiConstants.categoryById(id));
    return CategoryModel.fromJson(res.data["data"]);
  }
}