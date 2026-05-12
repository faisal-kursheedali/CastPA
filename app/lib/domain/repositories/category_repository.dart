import 'package:castpa/domain/entities/category.dart';

abstract interface class CategoryRepository {
  Future<List<Category>> getAllCategories();
  Future<List<Category>> getActiveCategories();
  Future<Category?> getCategoryById(String id);
  Future<String> createCategory(Category category);
  Future<void> updateCategory(Category category);
  Future<void> softDeleteCategory(String id);
  Future<bool> isTitleUnique(String title, {String? excludeId});
}
