// NOTE: the backend's public CategoryResponse DTO only exposes "name"
// (see CategoryResponse.java) — there is no "id" in this response.
// If you need category filtering on products by id, add "id" to
// CategoryResponse.java on the backend.
class CategoryModel {
  final String name;

  CategoryModel({required this.name});

  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      CategoryModel(name: json["name"] ?? "");
}