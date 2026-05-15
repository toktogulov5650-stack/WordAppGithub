class CategoryRecordModel {
  const CategoryRecordModel({
    required this.categoryId,
    required this.bestScore,
  });

  final int categoryId;
  final int bestScore;

  factory CategoryRecordModel.fromJson(Map<String, dynamic> json) {
    return CategoryRecordModel(
      categoryId: (json['categoryId'] as num?)?.toInt() ?? 0,
      bestScore: (json['bestScore'] as num?)?.toInt() ?? 0,
    );
  }
}
