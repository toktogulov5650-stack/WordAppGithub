import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/language/app_strings.dart';
import '../../../core/language/language_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/empty_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
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
      backgroundColor: const Color(0xFFFCFCFD),
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
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 30, 24, 132),
                  children: [
                    _ExplanationsHeader(title: strings.explanations),
                    const SizedBox(height: 26),
                    _CategoriesGrid(categories: categories, strings: strings),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ExplanationsHeader extends StatelessWidget {
  const _ExplanationsHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.displaySmall?.copyWith(
        fontSize: 33,
        height: 1.08,
        fontWeight: FontWeight.w800,
        letterSpacing: 0,
      ),
    );
  }
}

class _CategoriesGrid extends StatelessWidget {
  const _CategoriesGrid({required this.categories, required this.strings});

  final List<CategoryModel> categories;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 660 ? 3 : 2;
        final tileHeight = columns == 2 ? 204.0 : 188.0;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: categories.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            mainAxisExtent: tileHeight,
          ),
          itemBuilder: (context, index) {
            final category = categories[index];
            final metadata = _ExplanationCategoryMeta.fromCategory(
              category,
              index,
              strings,
            );

            return _CategoryTopicCard(
              category: category,
              metadata: metadata,
              strings: strings,
              onTap: () =>
                  context.push('/explanations/category/${category.id}'),
            );
          },
        );
      },
    );
  }
}

class _CategoryTopicCard extends StatelessWidget {
  const _CategoryTopicCard({
    required this.category,
    required this.metadata,
    required this.strings,
    required this.onTap,
  });

  final CategoryModel category;
  final _ExplanationCategoryMeta metadata;
  final AppStrings strings;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final wordCount = category.wordCount;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFE9E9EC)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 16,
                offset: Offset(0, 7),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: metadata.color.withValues(alpha: 0.11),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(metadata.icon, color: metadata.color, size: 23),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppColors.textTertiary.withValues(alpha: 0.62),
                    size: 12,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                category.name,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 16.5,
                  height: 1.18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  metadata.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 13,
                    height: 1.32,
                    letterSpacing: 0,
                  ),
                ),
              ),
              if (wordCount != null)
                Text(
                  strings.wordCount(wordCount),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: metadata.color,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExplanationCategoryMeta {
  const _ExplanationCategoryMeta({
    required this.icon,
    required this.color,
    required this.description,
  });

  final IconData icon;
  final Color color;
  final String description;

  static _ExplanationCategoryMeta fromCategory(
    CategoryModel category,
    int index,
    AppStrings strings,
  ) {
    final key = category.name.toLowerCase();

    if (_containsAny(key, const ['баз', 'фраз', 'basic', 'phrase'])) {
      return _ExplanationCategoryMeta(
        icon: Icons.chat_bubble_outline_rounded,
        color: AppColors.success,
        description: strings.basicExplanation,
      );
    }
    if (_containsAny(key, const ['глагол', 'действ', 'verb', 'action'])) {
      return _ExplanationCategoryMeta(
        icon: Icons.directions_run_rounded,
        color: AppColors.secondaryPurple,
        description: strings.verbsExplanation,
      );
    }
    if (_containsAny(key, const [
      'люди',
      'отнош',
      'семь',
      'друг',
      'people',
      'relationship',
      'family',
    ])) {
      return _ExplanationCategoryMeta(
        icon: Icons.people_outline_rounded,
        color: AppColors.actionBlue,
        description: strings.explanationFallback1,
      );
    }
    if (_containsAny(key, const ['дом', 'быт', 'home', 'house'])) {
      return _ExplanationCategoryMeta(
        icon: Icons.home_work_outlined,
        color: AppColors.warning,
        description: strings.explanationFallback1,
      );
    }
    if (_containsAny(key, const ['еда', 'напит', 'food', 'drink', 'fruit'])) {
      return _ExplanationCategoryMeta(
        icon: Icons.restaurant_menu_rounded,
        color: AppColors.warning,
        description: strings.foodExplanation,
      );
    }
    if (_containsAny(key, const ['тело', 'здоров', 'body', 'health'])) {
      return _ExplanationCategoryMeta(
        icon: Icons.health_and_safety_outlined,
        color: AppColors.success,
        description: strings.explanationFallback1,
      );
    }
    if (_containsAny(key, const ['путеше', 'транспорт', 'travel', 'trip'])) {
      return _ExplanationCategoryMeta(
        icon: Icons.travel_explore_rounded,
        color: AppColors.actionBlue,
        description: strings.travelExplanation,
      );
    }
    if (_containsAny(key, const [
      'работ',
      'професс',
      'career',
      'work',
      'job',
    ])) {
      return _ExplanationCategoryMeta(
        icon: Icons.work_outline_rounded,
        color: AppColors.secondaryPurple,
        description: strings.explanationFallback2,
      );
    }
    if (_containsAny(key, const [
      'учеб',
      'школ',
      'education',
      'school',
      'study',
    ])) {
      return _ExplanationCategoryMeta(
        icon: Icons.school_outlined,
        color: AppColors.secondaryPurple,
        description: strings.explanationFallback3,
      );
    }
    if (_containsAny(key, const ['время', 'день', 'time', 'date'])) {
      return _ExplanationCategoryMeta(
        icon: Icons.schedule_rounded,
        color: AppColors.actionBlue,
        description: strings.explanationFallback2,
      );
    }
    if (_containsAny(key, const ['цвет', 'color'])) {
      return _ExplanationCategoryMeta(
        icon: Icons.palette_outlined,
        color: AppColors.warning,
        description: strings.explanationFallback3,
      );
    }
    if (_containsAny(key, const ['числ', 'номер', 'number'])) {
      return _ExplanationCategoryMeta(
        icon: Icons.tag_rounded,
        color: AppColors.actionBlue,
        description: strings.explanationFallback2,
      );
    }
    if (_containsAny(key, const ['покуп', 'магаз', 'деньг', 'shop', 'money'])) {
      return _ExplanationCategoryMeta(
        icon: Icons.shopping_bag_outlined,
        color: AppColors.success,
        description: strings.explanationFallback1,
      );
    }

    final variants = [
      _ExplanationCategoryMeta(
        icon: Icons.auto_stories_rounded,
        color: AppColors.success,
        description: strings.explanationFallback1,
      ),
      _ExplanationCategoryMeta(
        icon: Icons.bookmarks_outlined,
        color: AppColors.secondaryPurple,
        description: strings.explanationFallback2,
      ),
      _ExplanationCategoryMeta(
        icon: Icons.menu_book_rounded,
        color: AppColors.actionBlue,
        description: strings.explanationFallback3,
      ),
      _ExplanationCategoryMeta(
        icon: Icons.psychology_alt_outlined,
        color: AppColors.warning,
        description: strings.explanationFallback1,
      ),
      _ExplanationCategoryMeta(
        icon: Icons.lightbulb_outline_rounded,
        color: AppColors.success,
        description: strings.explanationFallback2,
      ),
      _ExplanationCategoryMeta(
        icon: Icons.explore_outlined,
        color: AppColors.actionBlue,
        description: strings.explanationFallback3,
      ),
      _ExplanationCategoryMeta(
        icon: Icons.tips_and_updates_outlined,
        color: AppColors.warning,
        description: strings.explanationFallback1,
      ),
      _ExplanationCategoryMeta(
        icon: Icons.forum_outlined,
        color: AppColors.secondaryPurple,
        description: strings.explanationFallback2,
      ),
      _ExplanationCategoryMeta(
        icon: Icons.fact_check_outlined,
        color: AppColors.success,
        description: strings.explanationFallback3,
      ),
      _ExplanationCategoryMeta(
        icon: Icons.extension_outlined,
        color: AppColors.actionBlue,
        description: strings.explanationFallback1,
      ),
    ];

    return variants[index % variants.length];
  }

  static bool _containsAny(String text, List<String> values) {
    return values.any(text.contains);
  }
}
