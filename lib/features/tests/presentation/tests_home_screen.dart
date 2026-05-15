import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/language/app_strings.dart';
import '../../../core/language/language_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../core/widgets/section_title.dart';
import '../data/category_model.dart';
import '../providers/categories_provider.dart';

class TestsHomeScreen extends ConsumerWidget {
  const TestsHomeScreen({super.key});

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
            message: error is Exception
                ? error.toString().replaceFirst('Exception: ', '')
                : null,
            onRetry: () => ref.invalidate(categoriesProvider),
          ),
          data: (categories) {
            if (categories.isEmpty) {
              return EmptyView(title: strings.noCategories);
            }

            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async => ref.invalidate(categoriesProvider),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final maxWidth = math.min(constraints.maxWidth, 1040.0);
                  final columns = maxWidth >= 760 ? 2 : 1;
                  final cardWidth = columns == 1
                      ? maxWidth
                      : (maxWidth - 20) / 2;

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: maxWidth),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: SectionTitle(title: strings.categories),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: maxWidth),
                          child: Wrap(
                            spacing: 20,
                            runSpacing: 20,
                            children: [
                              for (
                                var index = 0;
                                index < categories.length;
                                index++
                              )
                                SizedBox(
                                  width: cardWidth,
                                  child: CategoryCard(
                                    category: categories[index],
                                    index: index,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class CategoryCard extends ConsumerWidget {
  const CategoryCard({required this.category, required this.index, super.key});

  final CategoryModel category;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.fromCode(
      ref.watch(languageProvider).languageCode,
    );
    final metadata = _CategoryMetadata.fromName(category.name, index, strings);

    return AppCard(
      radius: 26,
      onTap: () => context.push('/test/${category.id}'),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 168,
            decoration: BoxDecoration(
              color: metadata.background,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.border),
            ),
            child: Center(
              child: Container(
                width: 148,
                height: 98,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.78),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_outlined,
                      color: metadata.accent.withValues(alpha: 0.65),
                      size: 28,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      strings.image,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: metadata.accent.withValues(alpha: 0.72),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  category.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              if (category.wordCount != null) ...[
                const SizedBox(width: 12),
                _WordCountPill(count: category.wordCount!, strings: strings),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            metadata.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          AppButton(
            label: strings.start,
            onPressed: () => context.push('/test/${category.id}'),
          ),
        ],
      ),
    );
  }
}

class _WordCountPill extends StatelessWidget {
  const _WordCountPill({required this.count, required this.strings});

  final int count;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        strings.wordCount(count),
        style: Theme.of(
          context,
        ).textTheme.labelMedium?.copyWith(color: AppColors.textMuted),
      ),
    );
  }
}

class _CategoryMetadata {
  const _CategoryMetadata({
    required this.description,
    required this.background,
    required this.accent,
  });

  final String description;
  final Color background;
  final Color accent;

  static _CategoryMetadata fromName(
    String name,
    int index,
    AppStrings strings,
  ) {
    final key = name.toLowerCase();
    final fallbacks = _fallbacks(strings);
    final fallback = fallbacks[index % fallbacks.length];
    final lookup = <List<String>, _CategoryMetadata>{
      ['basic', 'beginner']: _CategoryMetadata(
        description: strings.basicDescription,
        background: const Color(0xFFF2FFF7),
        accent: const Color(0xFF4D8D68),
      ),
      ['travel']: _CategoryMetadata(
        description: strings.travelDescription,
        background: const Color(0xFFF2FFF7),
        accent: const Color(0xFF4D8D68),
      ),
      ['food', 'fruit']: _CategoryMetadata(
        description: strings.foodDescription,
        background: const Color(0xFFF2FFF7),
        accent: const Color(0xFF4D8D68),
      ),
      ['verb']: _CategoryMetadata(
        description: strings.verbsDescription,
        background: const Color(0xFFF2FFF7),
        accent: const Color(0xFF4D8D68),
      ),
    };

    for (final entry in lookup.entries) {
      if (entry.key.any((pattern) => key.contains(pattern))) {
        return entry.value;
      }
    }

    return fallback;
  }

  static List<_CategoryMetadata> _fallbacks(AppStrings strings) => [
    _CategoryMetadata(
      description: strings.fallbackDescription1,
      background: const Color(0xFFF2FFF7),
      accent: const Color(0xFF4D8D68),
    ),
    _CategoryMetadata(
      description: strings.fallbackDescription2,
      background: const Color(0xFFF2FFF7),
      accent: const Color(0xFF4D8D68),
    ),
    _CategoryMetadata(
      description: strings.fallbackDescription3,
      background: const Color(0xFFF2FFF7),
      accent: const Color(0xFF4D8D68),
    ),
  ];
}
