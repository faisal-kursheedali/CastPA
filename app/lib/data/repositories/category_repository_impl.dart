import 'package:drift/drift.dart';
import 'package:castpa/data/database/app_database.dart';
import 'package:castpa/domain/entities/category.dart' as domain;
import 'package:castpa/domain/entities/enums.dart';
import 'package:castpa/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final AppDatabase _db;

  CategoryRepositoryImpl(this._db);

  domain.Category _fromRow(Category row) {
    return domain.Category(
      id: row.id,
      name: row.name,
      description: row.description,
      createdDate: row.createdDate,
      status: CategoryStatus.fromKey(row.status),
    );
  }

  @override
  Future<List<domain.Category>> getAllCategories() async {
    final rows = await _db.select(_db.categories).get();
    return rows.map(_fromRow).toList();
  }

  @override
  Future<List<domain.Category>> getActiveCategories() async {
    final rows = await (_db.select(_db.categories)
          ..where((t) => t.status.equals(CategoryStatus.active.key)))
        .get();
    return rows.map(_fromRow).toList();
  }

  @override
  Future<domain.Category?> getCategoryById(String id) async {
    final row = await (_db.select(_db.categories)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _fromRow(row);
  }

  @override
  Future<String> createCategory(domain.Category category) async {
    await _db.into(_db.categories).insert(CategoriesCompanion(
      id: Value(category.id),
      name: Value(category.name),
      description: Value(category.description),
      createdDate: Value(category.createdDate),
      status: Value(category.status.key),
    ));
    return category.id;
  }

  @override
  Future<void> updateCategory(domain.Category category) async {
    await (_db.update(_db.categories)..where((t) => t.id.equals(category.id)))
        .write(CategoriesCompanion(
      name: Value(category.name),
      description: Value(category.description),
      status: Value(category.status.key),
    ));
  }

  @override
  Future<void> softDeleteCategory(String id) async {
    await (_db.update(_db.categories)..where((t) => t.id.equals(id)))
        .write(CategoriesCompanion(
      status: Value(CategoryStatus.inactive.key),
    ));
  }

  @override
  Future<bool> isTitleUnique(String title, {String? excludeId}) async {
    final query = _db.select(_db.categories)
      ..where((t) => t.name.lower().equals(title.toLowerCase()));
    final rows = await query.get();
    if (excludeId != null) {
      return rows.every((r) => r.id == excludeId);
    }
    return rows.isEmpty;
  }
}
