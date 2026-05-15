import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../data/record_api.dart';

final recordsProvider = FutureProvider.family<int, int>((
  ref,
  categoryId,
) async {
  try {
    final record = await ref
        .read(recordApiProvider)
        .getCategoryRecord(categoryId);
    return record.bestScore;
  } on ApiException catch (error) {
    if (error.isNotFound) {
      return 0;
    }
    rethrow;
  }
});
