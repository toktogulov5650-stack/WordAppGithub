class CategoryModel {
  const CategoryModel({required this.id, required this.name, this.wordCount});

  final int id;
  final String name;
  final int? wordCount;

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] as String?) ?? '',
      wordCount:
          (json['wordCount'] as num?)?.toInt() ??
          (json['wordsCount'] as num?)?.toInt() ??
          (json['count'] as num?)?.toInt(),
    );
  }
}
