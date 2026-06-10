import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/language/app_strings.dart';
import '../../../core/language/language_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../auth/data/auth_models.dart';
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: userAsync.when(
          loading: () => LoadingView(message: strings.profileLoading),
          error: (error, stackTrace) => ErrorView(
            title: strings.profileLoadFailed,
            onRetry: () => ref.invalidate(profileUserProvider),
          ),
          data: (user) {
            final horizontalPadding = Responsive.horizontalPadding(
              context,
              compact: 20,
              regular: 26,
              wide: 30,
            );
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    Responsive.verticalGap(context, 24),
                    horizontalPadding,
                    112,
                  ),
                  children: [
                    _ProfileHero(user: user, strings: strings),
                    SizedBox(height: Responsive.verticalGap(context, 46)),
                    _CategoryRecordsSection(
                      key: ValueKey(user.id),
                      userId: user.id,
                      categoriesAsync: categoriesAsync,
                      strings: strings,
                    ),
                    SizedBox(height: Responsive.verticalGap(context, 54)),
                    _LanguagePanel(
                      languageCode: languageCode,
                      strings: strings,
                      isLoading: authState.isLoading,
                      errorMessage: authState.errorMessage,
                      onChanged: (selectedLanguage) async {
                        await ref
                            .read(authProvider.notifier)
                            .changePreferredLanguage(selectedLanguage);
                        if (context.mounted &&
                            ref.read(authProvider).errorMessage == null) {
                          final updatedStrings = AppStrings.fromCode(
                            selectedLanguage,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(updatedStrings.languageSaved),
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 28),
                    _LogoutTile(
                      label: strings.logout,
                      onTap: () async {
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
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.user, required this.strings});

  final UserModel user;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final letter = user.name.trim().isNotEmpty
        ? user.name.trim().substring(0, 1).toUpperCase()
        : '?';

    final displayName = user.name.trim().isEmpty ? user.email : user.name;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _ProfileAvatar(
          letter: letter,
        ),
        const SizedBox(height: 18),
        Text(
          displayName,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: Responsive.font(context, 28),
            height: 1.12,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.alternate_email_rounded,
              size: 17,
              color: AppColors.textTertiary,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                user.email,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textMuted,
                  height: 1.2,
                  fontSize: Responsive.font(context, 16),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.letter});

  final String letter;

  @override
  Widget build(BuildContext context) {
    final size = Responsive.value(
      context,
      120,
      minScale: 0.86,
      maxScale: 1,
    );
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.textDark,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE9E9EC), width: 4),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: _AvatarLetter(letter: letter),
    );
  }
}

class _AvatarLetter extends StatelessWidget {
  const _AvatarLetter({required this.letter});

  final String letter;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        letter,
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          color: Colors.white,
          fontSize: Responsive.font(context, 44, maxScale: 1),
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _LanguagePanel extends StatelessWidget {
  const _LanguagePanel({
    required this.languageCode,
    required this.strings,
    required this.isLoading,
    required this.errorMessage,
    required this.onChanged,
  });

  final String languageCode;
  final AppStrings strings;
  final bool isLoading;
  final String? errorMessage;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PanelTitle(
          icon: Icons.translate_rounded,
          iconColor: AppColors.actionBlue,
          title: strings.appLanguage,
        ),
        const SizedBox(height: 14),
        Container(
          height: 54,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE9E9EC)),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadowSoft,
                blurRadius: 12,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _LanguageOption(
                  label: strings.kyrgyz,
                  selected: languageCode == 'ky',
                  onTap: isLoading ? null : () => onChanged('ky'),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _LanguageOption(
                  label: strings.russian,
                  selected: languageCode == 'ru',
                  onTap: isLoading ? null : () => onChanged('ru'),
                ),
              ),
            ],
          ),
        ),
        if (errorMessage != null) ...[
          const SizedBox(height: 10),
          Text(
            errorMessage!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.error,
              letterSpacing: 0,
            ),
          ),
        ],
      ],
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Ink(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.textDark : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: selected
                ? const [
                    BoxShadow(
                      color: AppColors.shadowSoft,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: selected ? Colors.white : AppColors.textMuted,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryRecordsSection extends StatelessWidget {
  const _CategoryRecordsSection({
    super.key,
    required this.userId,
    required this.categoriesAsync,
    required this.strings,
  });

  final int userId;
  final AsyncValue<List<CategoryModel>> categoriesAsync;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return categoriesAsync.when(
      loading: () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PanelTitle(
            icon: Icons.emoji_events_outlined,
            iconColor: AppColors.warning,
            title: strings.bestScore,
            subtitle: strings.categories,
          ),
          const SizedBox(height: 24),
          const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.6),
            ),
          ),
        ],
      ),
      error: (_, _) => _PanelTitle(
        icon: Icons.emoji_events_outlined,
        iconColor: AppColors.warning,
        title: strings.bestScore,
        subtitle: strings.categoriesLoadFailed,
      ),
      data: (categories) {
        if (categories.isEmpty) {
          return _PanelTitle(
            icon: Icons.emoji_events_outlined,
            iconColor: AppColors.warning,
            title: strings.bestScore,
            subtitle: strings.noCategories,
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PanelTitle(
              icon: Icons.emoji_events_outlined,
              iconColor: AppColors.warning,
              title: strings.bestScore,
              subtitle: strings.categories,
            ),
            const SizedBox(height: 22),
            for (var index = 0; index < categories.length; index++) ...[
              _CategoryRecordTile(
                userId: userId,
                category: categories[index],
                strings: strings,
              ),
              if (index != categories.length - 1)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Divider(height: 1, color: Color(0xFFF3F3F5)),
                ),
            ],
          ],
        );
      },
    );
  }
}

class _PanelTitle extends StatelessWidget {
  const _PanelTitle({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: Responsive.value(context, 40),
          height: Responsive.value(context, 40),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: iconColor, size: 21),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 3),
                Text(
                  subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _CategoryRecordTile extends ConsumerWidget {
  const _CategoryRecordTile({
    required this.userId,
    required this.category,
    required this.strings,
  });

  final int userId;
  final CategoryModel category;
  final AppStrings strings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordAsync = ref.watch(
      recordsProvider(
        CategoryRecordKey(userId: userId, categoryId: category.id),
      ),
    );
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              valueText,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.textDark,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppColors.textTertiary,
            fontSize: 11,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 7,
            value: progress.clamp(0, 1),
            backgroundColor: AppColors.success.withValues(alpha: 0.10),
            color: AppColors.success,
          ),
        ),
      ],
    );
  }
}

class _LogoutTile extends StatelessWidget {
  const _LogoutTile({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [ 
        const Divider(height: 1, color: Color(0xFFF3F3F5)),
        const SizedBox(height: 10),
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.errorSurface.withValues(alpha: 0.62),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(
                      Icons.logout_rounded,
                      color: AppColors.errorDark,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.errorDark,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
