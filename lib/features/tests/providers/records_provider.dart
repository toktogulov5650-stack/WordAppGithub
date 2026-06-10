import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/storage/token_storage.dart';
import '../data/record_api.dart';

final recordsProvider = FutureProvider.family<int, CategoryRecordKey>((
  ref,
  key,
) async {
  final token = await ref.read(tokenStorageProvider).readToken();
  if (token == null || token.isEmpty) {
    return 0;
  }

  try {
    final record = await ref
        .read(recordApiProvider)
        .getCategoryRecord(key.categoryId, token: token);
    return record.bestScore;
  } on ApiException catch (error) {
    if (error.isNotFound) {
      return 0;
    }
    rethrow;
  }
});

class CategoryRecordKey {
  const CategoryRecordKey({required this.userId, required this.categoryId});

  final int userId;
  final int categoryId;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is CategoryRecordKey &&
            other.userId == userId &&
            other.categoryId == categoryId;
  }

  @override
  int get hashCode => Object.hash(userId, categoryId);
}
