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
import '../providers/test_provider.dart';

class ResultScreen extends ConsumerWidget {
  const ResultScreen({required this.testSessionId, super.key});

  final int testSessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultAsync = ref.watch(finishTestProvider(testSessionId));
    final testState = ref.watch(testProvider);
    final strings = AppStrings.fromCode(
      ref.watch(languageProvider).languageCode,
    );

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: resultAsync.when(
          loading: () => LoadingView(message: strings.resultLoading),
          error: (error, _) => ErrorView(
            title: strings.resultLoadFailed,
            onRetry: () => ref.invalidate(finishTestProvider(testSessionId)),
          ),
          data: (result) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppCard(
                        radius: 28,
                        padding: const EdgeInsets.fromLTRB(22, 28, 22, 22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: Container(
                                width: 70,
                                height: 70,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: AppColors.successSurface,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: AppColors.success.withValues(
                                      alpha: 0.3,
                                    ),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  color: AppColors.successDark,
                                  size: 34,
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              '${result.correctAnswerCount}',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.displaySmall
                                  ?.copyWith(
                                    fontSize: 70,
                                    color: AppColors.successDark,
                                  ),
                            ),
                            Text(
                              strings.correctAnswers,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(color: AppColors.textMuted),
                            ),
                            const SizedBox(height: 22),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.emoji_events_outlined,
                                    color: AppColors.successDark,
                                    size: 21,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    '${strings.bestScore}: ${result.bestScore}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(color: AppColors.textDark),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      AppButton(
                        label: strings.restart,
                        icon: Icons.refresh_rounded,
                        onPressed: testState.currentCategoryId == null
                            ? null
                            : () {
                                final categoryId = testState.currentCategoryId!;
                                ref.read(testProvider.notifier).clear();
                                context.go('/test/$categoryId');
                              },
                      ),
                      const SizedBox(height: 12),
                      AppButton(
                        label: strings.unknownWords,
                        variant: AppButtonVariant.secondary,
                        icon: Icons.help_outline_rounded,
                        onPressed: () =>
                            context.push('/unknown-words/$testSessionId'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
