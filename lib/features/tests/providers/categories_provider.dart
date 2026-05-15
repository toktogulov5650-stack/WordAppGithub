import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/language/language_provider.dart';
import '../data/categories_api.dart';
import '../data/category_model.dart';

final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  final languageCode = ref.watch(languageProvider).languageCode;
  return ref
      .read(categoriesApiProvider)
      .getCategories(languageCode: languageCode);
});
