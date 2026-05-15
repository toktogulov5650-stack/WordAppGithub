import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/language/app_strings.dart';
import '../../../core/language/language_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../core/widgets/section_title.dart';
import '../../auth/providers/auth_provider.dart';
import '../../tests/data/category_model.dart';
import '../../tests/providers/categories_provider.dart';
import '../../tests/providers/records_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final languageCode =
        ref.watch(languageProvider).languageCode ?? defaultLanguageCode;
    final strings = AppStrings.fromCode(languageCode);
    final userAsync = authState.user != null
        ? AsyncData(authState.user!)
        : ref.watch(profileUserProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: userAsync.when(
            loading: () => LoadingView(message: strings.profileLoading),
            error: (error, stackTrace) => ErrorView(
              title: strings.profileLoadFailed,
              onRetry: () => ref.invalidate(profileUserProvider),
            ),
            data: (user) {
              final letter = user.name.isNotEmpty
                  ? user.name[0].toUpperCase()
                  : '?';

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: ListView(
                    children: [
                      SectionTitle(
                        title: strings.profile,
                        subtitle: strings.profileSubtitle,
                      ),
                      const SizedBox(height: 20),
                      AppCard(
                        radius: 28,
                        padding: const EdgeInsets.all(22),
                        child: Row(
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Center(
                                child: Text(
                                  letter,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(fontSize: 28),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.name,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    user.email,
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      _CategoryRecordsSection(
                        categoriesAsync: categoriesAsync,
                        strings: strings,
                      ),
                      const SizedBox(height: 14),
                      AppCard(
                        radius: 24,
                        padding: const EdgeInsets.all(18),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.successSurface,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.verified_user_outlined,
                                color: AppColors.successDark,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    strings.accountActive,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    strings.accountActiveSubtitle,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      AppCard(
                        radius: 24,
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: const Icon(
                                    Icons.translate_rounded,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    strings.appLanguage,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SegmentedButton<String>(
                              segments: [
                                ButtonSegment(
                                  value: 'ky',
                                  label: Text(strings.kyrgyz),
                                ),
                                ButtonSegment(
                                  value: 'ru',
                                  label: Text(strings.russian),
                                ),
                              ],
                              selected: {languageCode},
                              onSelectionChanged: authState.isLoading
                                  ? null
                                  : (selection) async {
                                      final selectedLanguage = selection.single;
                                      await ref
                                          .read(authProvider.notifier)
                                          .changePreferredLanguage(
                                            selectedLanguage,
                                          );
                                      if (context.mounted &&
                                          ref.read(authProvider).errorMessage ==
                                              null) {
                                        final updatedStrings =
                                            AppStrings.fromCode(
                                              selectedLanguage,
                                            );
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              updatedStrings.languageSaved,
                                            ),
                                          ),
                                        );
                                      }
                                    },
                            ),
                            if (authState.errorMessage != null) ...[
                              const SizedBox(height: 10),
                              Text(
                                authState.errorMessage!,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppColors.error),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      AppButton(
                        label: strings.logout,
                        variant: AppButtonVariant.danger,
                        onPressed: () async {
                          await ref.read(authProvider.notifier).logout();
                          if (context.mounted) {
                            context.go('/login');
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CategoryRecordsSection extends StatelessWidget {
  const _CategoryRecordsSection({
    required this.categoriesAsync,
    required this.strings,
  });

  final AsyncValue<List<CategoryModel>> categoriesAsync;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      radius: 24,
      padding: const EdgeInsets.all(18),
      child: categoriesAsync.when(
        loading: () => const SizedBox(
          height: 72,
          child: Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.6),
            ),
          ),
        ),
        error: (_, _) => _RecordsHeader(
          title: strings.bestScore,
          subtitle: strings.categoriesLoadFailed,
        ),
        data: (categories) {
          if (categories.isEmpty) {
            return _RecordsHeader(
              title: strings.bestScore,
              subtitle: strings.noCategories,
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _RecordsHeader(
                      title: strings.bestScore,
                      subtitle: strings.categories,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.cardSecondary,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      '${categories.length}',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.textDark,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              for (var index = 0; index < categories.length; index++) ...[
                _CategoryRecordTile(
                  category: categories[index],
                  strings: strings,
                ),
                if (index != categories.length - 1) const SizedBox(height: 10),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _RecordsHeader extends StatelessWidget {
  const _RecordsHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.verySoftGreen,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: const Icon(
            Icons.emoji_events_outlined,
            color: AppColors.successDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CategoryRecordTile extends ConsumerWidget {
  const _CategoryRecordTile({required this.category, required this.strings});

  final CategoryModel category;
  final AppStrings strings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordAsync = ref.watch(recordsProvider(category.id));
    final total = (category.wordCount == null || category.wordCount! <= 0)
        ? 100
        : category.wordCount!;

    return recordAsync.when(
      loading: () => _RecordProgressRow(
        title: category.name,
        label: strings.bestScore,
        valueText: '.../$total',
        progress: 0,
      ),
      error: (_, _) => _RecordProgressRow(
        title: category.name,
        label: strings.bestScore,
        valueText: '0/$total',
        progress: 0,
      ),
      data: (bestScore) {
        final safeScore = bestScore.clamp(0, total);
        return _RecordProgressRow(
          title: category.name,
          label: strings.bestScore,
          valueText: '$safeScore/$total',
          progress: total == 0 ? 0 : safeScore / total,
        );
      },
    );
  }
}

class _RecordProgressRow extends StatelessWidget {
  const _RecordProgressRow({
    required this.title,
    required this.label,
    required this.valueText,
    required this.progress,
  });

  final String title;
  final String label;
  final String valueText;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardSecondary,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                valueText,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.successDark,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.textMuted,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: progress.clamp(0, 1),
              backgroundColor: Colors.white,
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
}
