import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/language/app_strings.dart';
import '../../../core/language/language_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/empty_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
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
      backgroundColor: Colors.white,
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
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  Responsive.horizontalPadding(
                    context,
                    compact: 20,
                    regular: 22,
                    wide: 26,
                  ),
                  Responsive.verticalGap(context, 26),
                  Responsive.horizontalPadding(
                    context,
                    compact: 20,
                    regular: 22,
                    wide: 26,
                  ),
                  116,
                ),
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 760),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _TestsHeader(title: strings.tests),
                          SizedBox(height: Responsive.verticalGap(context, 20)),
                          _TestCategoriesGrid(
                            categories: categories,
                            strings: strings,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TestsHeader extends StatelessWidget {
  const _TestsHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.displaySmall?.copyWith(
        fontSize: Responsive.font(context, 33),
        height: 1.08,
        fontWeight: FontWeight.w800,
        letterSpacing: 0,
      ),
    );
  }
}

class _TestCategoriesGrid extends StatelessWidget {
  const _TestCategoriesGrid({required this.categories, required this.strings});

  final List<CategoryModel> categories;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 660 ? 2 : 1;
        final isCompact = constraints.maxWidth < 370;
        final imageHeight = columns == 1
            ? (isCompact ? 178.0 : 206.0)
            : 204.0;
        final cardHeight = imageHeight + (isCompact ? 82.0 : 96.0);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: categories.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            mainAxisExtent: cardHeight,
          ),
          itemBuilder: (context, index) {
            final category = categories[index];
            final metadata = _CategoryMetadata.fromName(
              category.name,
              index,
              strings,
            );

            return _CategoryCard(
              category: category,
              metadata: metadata,
              strings: strings,
              imageHeight: imageHeight,
              onTap: () => context.push('/test/${category.id}'),
            );
          },
        );
      },
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.metadata,
    required this.strings,
    required this.imageHeight,
    required this.onTap,
  });

  final CategoryModel category;
  final _CategoryMetadata metadata;
  final AppStrings strings;
  final double imageHeight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFF1F1F3)),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadowSoft,
                blurRadius: 14,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CategoryImage(
                imageAsset: metadata.imageAsset,
                icon: metadata.icon,
                color: metadata.color,
                wordCount: category.wordCount,
                strings: strings,
                imageHeight: imageHeight,
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    Responsive.isCompact(context) ? 13 : 14,
                    10,
                    Responsive.isCompact(context) ? 13 : 14,
                    12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        category.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: Responsive.font(context, 17),
                          height: 1.22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        metadata.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textMuted,
                          fontSize: Responsive.font(context, 13),
                          height: 1.36,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryImage extends StatelessWidget {
  const _CategoryImage({
    required this.imageAsset,
    required this.icon,
    required this.color,
    required this.wordCount,
    required this.strings,
    required this.imageHeight,
  });

  final String? imageAsset;
  final IconData icon;
  final Color color;
  final int? wordCount;
  final AppStrings strings;
  final double imageHeight;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
      child: SizedBox(
        width: double.infinity,
        height: imageHeight,
        child: Stack(
          fit: StackFit.expand,
          children: [
            imageAsset == null
                ? _CategoryImageFallback(icon: icon, color: color)
                : Image.asset(
                    imageAsset!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _CategoryImageFallback(icon: icon, color: color),
                  ),
            if (wordCount != null)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    strings.wordCount(wordCount!),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.textDark,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CategoryImageFallback extends StatelessWidget {
  const _CategoryImageFallback({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: color.withValues(alpha: 0.07),
      child: Center(
        child: Icon(icon, color: color.withValues(alpha: 0.82), size: 42),
      ),
    );
  }
}

class _CategoryMetadata {
  const _CategoryMetadata({
    required this.description,
    required this.icon,
    required this.color,
    required this.imageAsset,
  });

  final String description;
  final IconData icon;
  final Color color;
  final String? imageAsset;

  static _CategoryMetadata fromName(
    String name,
    int index,
    AppStrings strings,
  ) {
    final key = name.toLowerCase();

    if (_containsAny(key, const ['basic', 'beginner', 'phrase'])) {
      return _CategoryMetadata(
        description: strings.basicDescription,
        icon: Icons.chat_bubble_outline_rounded,
        color: AppColors.success,
        imageAsset: null,
      );
    }
    if (_containsAny(key, const ['verb', 'action'])) {
      return _CategoryMetadata(
        description: strings.verbsDescription,
        icon: Icons.directions_run_rounded,
        color: AppColors.secondaryPurple,
        imageAsset: null,
      );
    }
    if (_containsAny(key, const ['travel', 'trip'])) {
      return _CategoryMetadata(
        description: strings.travelDescription,
        icon: Icons.travel_explore_rounded,
        color: AppColors.actionBlue,
        imageAsset: null,
      );
    }
    if (_containsAny(key, const ['food', 'fruit', 'drink'])) {
      return _CategoryMetadata(
        description: strings.foodDescription,
        icon: Icons.restaurant_menu_rounded,
        color: AppColors.warning,
        imageAsset: null,
      );
    }
    if (_containsAny(key, const ['nature', 'природ'])) {
      return _CategoryMetadata(
        description: strings.fallbackDescription1,
        icon: Icons.landscape_outlined,
        color: AppColors.success,
        imageAsset: 'assets/images/nature.jpg',
      );
    }

    final variants = [
      _CategoryMetadata(
        description: strings.fallbackDescription1,
        icon: Icons.auto_stories_outlined,
        color: AppColors.success,
        imageAsset: null,
      ),
      _CategoryMetadata(
        description: strings.fallbackDescription2,
        icon: Icons.psychology_alt_outlined,
        color: AppColors.secondaryPurple,
        imageAsset: null,
      ),
      _CategoryMetadata(
        description: strings.fallbackDescription3,
        icon: Icons.fact_check_outlined,
        color: AppColors.actionBlue,
        imageAsset: null,
      ),
      _CategoryMetadata(
        description: strings.fallbackDescription1,
        icon: Icons.lightbulb_outline_rounded,
        color: AppColors.warning,
        imageAsset: null,
      ),
      _CategoryMetadata(
        description: strings.fallbackDescription2,
        icon: Icons.school_outlined,
        color: AppColors.success,
        imageAsset: null,
      ),
      _CategoryMetadata(
        description: strings.fallbackDescription3,
        icon: Icons.explore_outlined,
        color: AppColors.secondaryPurple,
        imageAsset: null,
      ),
    ];

    return variants[index % variants.length];
  }

  static bool _containsAny(String text, List<String> values) {
    return values.any(text.contains);
  }
}
