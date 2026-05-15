import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/language/app_strings.dart';
import '../../../core/language/language_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../core/widgets/section_title.dart';
import '../../tests/data/category_model.dart';
import '../../tests/providers/categories_provider.dart';

class ExplanationsHomeScreen extends ConsumerWidget {
  const ExplanationsHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final strings = AppStrings.fromCode(
      ref.watch(languageProvider).languageCode,
    );

    return Scaffold(
      body: SafeArea(
        child: categoriesAsync.when(
          loading: () => LoadingView(message: strings.categoriesLoading),
          error: (error, stackTrace) => ErrorView(
            title: strings.categoriesLoadFailed,
            onRetry: () => ref.invalidate(categoriesProvider),
          ),
          data: (categories) {
            if (categories.isEmpty) {
              return EmptyView(title: strings.noExplanationCategories);
            }

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 112),
                  itemCount: categories.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: SectionTitle(title: strings.explanations),
                        ),
                      );
                    }

                    final category = categories[index - 1];
                    final metadata = _ExplanationCategoryMeta.fromCategory(
                      category,
                      index,
                      strings,
                    );

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AppCard(
                        radius: 24,
                        onTap: () => context.push(
                          '/explanations/category/${category.id}',
                        ),
                        padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
                        child: Row(
                          children: [
                            Container(
                              width: 66,
                              height: 66,
                              decoration: BoxDecoration(
                                color: metadata.iconBackground,
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Icon(
                                metadata.icon,
                                color: AppColors.textDark,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    category.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontSize: 18),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    metadata.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: AppColors.cardSecondary,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.chevron_right_rounded,
                                color: AppColors.textTertiary,
                                size: 22,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ExplanationCategoryMeta {
  const _ExplanationCategoryMeta({
    required this.icon,
    required this.iconBackground,
    required this.description,
  });

  final IconData icon;
  final Color iconBackground;
  final String description;

  static _ExplanationCategoryMeta fromCategory(
    CategoryModel category,
    int index,
    AppStrings strings,
  ) {
    final key = category.name.toLowerCase();

    if (key.contains('этиш') || key.contains('verb')) {
      return _ExplanationCategoryMeta(
        icon: Icons.directions_run_rounded,
        iconBackground: AppColors.verySoftGreen,
        description: strings.verbsExplanation,
      );
    }
    if (key.contains('саякат') || key.contains('travel')) {
      return _ExplanationCategoryMeta(
        icon: Icons.public_rounded,
        iconBackground: AppColors.verySoftGreen,
        description: strings.travelExplanation,
      );
    }
    if (key.contains('жемиш') ||
        key.contains('food') ||
        key.contains('fruit')) {
      return _ExplanationCategoryMeta(
        icon: Icons.restaurant_menu_rounded,
        iconBackground: AppColors.verySoftGreen,
        description: strings.foodExplanation,
      );
    }
    if (key.contains('негиз') || key.contains('basic')) {
      return _ExplanationCategoryMeta(
        icon: Icons.lightbulb_outline_rounded,
        iconBackground: AppColors.verySoftGreen,
        description: strings.basicExplanation,
      );
    }

    final variants = [
      _ExplanationCategoryMeta(
        icon: Icons.auto_stories_rounded,
        iconBackground: AppColors.verySoftGreen,
        description: strings.explanationFallback1,
      ),
      _ExplanationCategoryMeta(
        icon: Icons.bookmarks_outlined,
        iconBackground: AppColors.verySoftGreen,
        description: strings.explanationFallback2,
      ),
      _ExplanationCategoryMeta(
        icon: Icons.menu_book_rounded,
        iconBackground: AppColors.verySoftGreen,
        description: strings.explanationFallback3,
      ),
    ];

    return variants[index % variants.length];
  }
}
