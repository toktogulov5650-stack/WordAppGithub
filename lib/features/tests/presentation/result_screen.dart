import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/language/app_strings.dart';
import '../../../core/language/language_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive.dart';
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
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white),
      body: SafeArea(
        child: resultAsync.when(
          loading: () => LoadingView(message: strings.resultLoading),
          error: (error, _) => ErrorView(
            title: strings.resultLoadFailed,
            onRetry: () => ref.invalidate(finishTestProvider(testSessionId)),
          ),
          data: (result) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final horizontalPadding = Responsive.horizontalPadding(
                  context,
                  compact: 20,
                  regular: 26,
                );
                final summaryTopGap = (constraints.maxHeight * 0.08).clamp(
                  18.0,
                  72.0,
                );
                return Center(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      8,
                      horizontalPadding,
                      28,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 430),
                      child: SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight - 44,
                          ),
                          child: IntrinsicHeight(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SizedBox(height: summaryTopGap),
                                _ResultSummary(
                                  score: result.correctAnswerCount,
                                  bestScore: result.bestScore,
                                  strings: strings,
                                ),
                                const Spacer(),
                                _ResultActions(
                                  strings: strings,
                                  onRestart:
                                      testState.currentCategoryId == null
                                      ? null
                                      : () {
                                          final categoryId =
                                              testState.currentCategoryId!;
                                          ref
                                              .read(testProvider.notifier)
                                              .clear();
                                          context.go('/test/$categoryId');
                                        },
                                  onUnknownWords: () => context.push(
                                    '/unknown-words/$testSessionId',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _ResultSummary extends StatelessWidget {
  const _ResultSummary({
    required this.score,
    required this.bestScore,
    required this.strings,
  });

  final int score;
  final int bestScore;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Text(
          strings.testFinished,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontSize: Responsive.font(context, 32),
            height: 1.1,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 26),
        Text(
          '$score',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontSize: Responsive.font(context, 76, minScale: 0.86, maxScale: 1),
            height: 0.96,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 16),
        _CorrectAnswersPill(label: strings.correctAnswers),
        const SizedBox(height: 26),
        _RecordLine(bestScore: bestScore, strings: strings),
      ],
    );
  }
}

class _CorrectAnswersPill extends StatelessWidget {
  const _CorrectAnswersPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: AppColors.success,
            size: 19,
          ),
          const SizedBox(width: 7),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textMuted,
              fontSize: Responsive.font(context, 15.5),
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordLine extends StatelessWidget {
  const _RecordLine({required this.bestScore, required this.strings});

  final int bestScore;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFF7D9),
              Color(0xFFFFEDB2),
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE9CA67)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14D6A70D),
              blurRadius: 12,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.workspace_premium_rounded,
              color: Color(0xFF8E6810),
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              '${strings.bestScore}: $bestScore',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: const Color(0xFF5A4105),
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultActions extends StatelessWidget {
  const _ResultActions({
    required this.strings,
    required this.onRestart,
    required this.onUnknownWords,
  });

  final AppStrings strings;
  final VoidCallback? onRestart;
  final VoidCallback onUnknownWords;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: _ResultButton(
            label: strings.restart,
            icon: Icons.refresh_rounded,
            onPressed: onRestart,
            isPrimary: true,
          ),
        ),
        const SizedBox(height: 9),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: _ResultButton(
            label: strings.unknownWords,
            icon: Icons.help_outline_rounded,
            onPressed: onUnknownWords,
          ),
        ),
      ],
    );
  }
}

class _ResultButton extends StatelessWidget {
  const _ResultButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isPrimary = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final background = isPrimary
        ? AppColors.textDark
        : const Color(0xFFFAFAFB);
    final foreground = isPrimary ? Colors.white : AppColors.textDark;
    final border = isPrimary ? AppColors.textDark : const Color(0xFFE2E2E6);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: onPressed == null ? 0.55 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Ink(
            height: 52,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(17),
              border: Border.all(color: border),
              boxShadow: isPrimary
                  ? const [
                      BoxShadow(
                        color: AppColors.shadowSoft,
                        blurRadius: 12,
                        offset: Offset(0, 5),
                      ),
                    ]
                  : const [
                      BoxShadow(
                        color: Color(0x06000000),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: foreground, size: 18),
                const SizedBox(width: 9),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: foreground,
                      fontSize: 14.5,
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
    );
  }
}
