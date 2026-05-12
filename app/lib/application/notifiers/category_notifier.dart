import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:castpa/application/providers/repository_providers.dart';
import 'package:castpa/domain/entities/category.dart';
import 'package:castpa/domain/entities/enums.dart';

class CategoryNotifier extends AsyncNotifier<List<Category>> {
  static const _uuid = Uuid();

  @override
  Future<List<Category>> build() async {
    return ref.watch(categoryRepositoryProvider).getAllCategories();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(categoryRepositoryProvider).getAllCategories(),
    );
  }

  Future<String?> createCategory({
    required String name,
    required String description,
  }) async {
    final repo = ref.read(categoryRepositoryProvider);
    final isUnique = await repo.isTitleUnique(name);
    if (!isUnique) return 'A category with this name already exists.';

    final category = Category(
      id: _uuid.v4(),
      name: name,
      description: description,
      createdDate: DateTime.now(),
      status: CategoryStatus.active,
    );
    await repo.createCategory(category);
    await refresh();
    return null;
  }

  Future<String?> updateCategory({
    required String id,
    required String name,
    required String description,
  }) async {
    final repo = ref.read(categoryRepositoryProvider);
    final isUnique = await repo.isTitleUnique(name, excludeId: id);
    if (!isUnique) return 'A category with this name already exists.';

    final existing = await repo.getCategoryById(id);
    if (existing == null) return 'Category not found.';

    await repo.updateCategory(existing.copyWith(name: name, description: description));
    await refresh();
    return null;
  }

  Future<void> softDelete(String id) async {
    await ref.read(categoryRepositoryProvider).softDeleteCategory(id);
    await refresh();
  }
}

final categoryNotifierProvider =
    AsyncNotifierProvider<CategoryNotifier, List<Category>>(CategoryNotifier.new);
