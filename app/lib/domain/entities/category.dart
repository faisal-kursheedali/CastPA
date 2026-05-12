import 'package:castpa/domain/entities/enums.dart';

class Category {
  final String id;
  final String name;
  final String description;
  final DateTime createdDate;
  final CategoryStatus status;

  const Category({
    required this.id,
    required this.name,
    required this.description,
    required this.createdDate,
    required this.status,
  });

  bool get isActive => status == CategoryStatus.active;

  Category copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? createdDate,
    CategoryStatus? status,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdDate: createdDate ?? this.createdDate,
      status: status ?? this.status,
    );
  }
}
