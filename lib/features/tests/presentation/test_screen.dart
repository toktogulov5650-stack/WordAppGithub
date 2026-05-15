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

class TestScreen extends ConsumerStatefulWidget {
  const TestScreen({required this.categoryId, super.key});

  final int categoryId;

  @override
  ConsumerState<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends ConsumerState<TestScreen> {
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) {
      return;
    }
    _started = true;
    Future.microtask(
      () => ref.read(testProvider.notifier).startTest(widget.categoryId),
    );
  }

  void _leaveTest() {
    final sessionId = ref.read(testProvider).testSessionId;
    if (sessionId != null) {
      context.go('/result/$sessionId');
      return;
    }
    ref.read(testProvider.notifier).clear();
    context.go('/?tab=0');
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<TestState>(testProvider, (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage &&
          mounted &&
          next.currentQuestion != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.errorMessage!)));
      }
    });

    final state = ref.watch(testProvider);
    final question = state.currentQuestion;
    final strings = AppStrings.fromCode(
      ref.watch(languageProvider).languageCode,
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _leaveTest();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: _leaveTest,
          ),
          title: Text(strings.test),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Builder(
              builder: (context) {
                if (state.isLoading) {
                  return LoadingView(message: strings.testPreparing);
                }

                if (question == null) {
                  return ErrorView(
                    title: strings.testStartFailed,
                    message: state.errorMessage,
                    onRetry: () => ref
                        .read(testProvider.notifier)
                        .startTest(widget.categoryId),
                  );
                }

                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: ListView(
                      children: [
                        _ProgressHeader(state: state, strings: strings),
                        if (state.lastAnswerCorrect != null) ...[
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: _AnswerFeedbackChip(
                              isCorrect: state.lastAnswerCorrect!,
                              strings: strings,
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        AppCard(
                          radius: 28,
                          padding: const EdgeInsets.fromLTRB(24, 22, 24, 28),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Text(
                                  strings.englishWord,
                                  style: Theme.of(context).textTheme.labelMedium
                                      ?.copyWith(color: AppColors.textMuted),
                                ),
                              ),
                              const SizedBox(height: 18),
                              Text(
                                question.englishWord,
                                style: Theme.of(context).textTheme.displaySmall
                                    ?.copyWith(fontSize: 42),
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        _AnswerGrid(
                          answers: question.answerOptions,
                          selectedAnswer: state.selectedAnswer,
                          isLocked: state.isLocked,
                          lastAnswerCorrect: state.lastAnswerCorrect,
                          onTap: (answer) async {
                            final sessionId = await ref
                                .read(testProvider.notifier)
                                .submitAnswer(answer);
                            if (sessionId != null && context.mounted) {
                              context.go('/result/$sessionId');
                            }
                          },
                        ),
                        const SizedBox(height: 18),
                        AppButton(
                          label: state.isMarkedUnknown
                              ? strings.markedUnknown
                              : strings.dontKnow,
                          height: 52,
                          variant: AppButtonVariant.warning,
                          onPressed: state.isLocked
                              ? null
                              : () async {
                                  final sessionId = await ref
                                      .read(testProvider.notifier)
                                      .submitUnknownAnswer();
                                  if (sessionId != null && context.mounted) {
                                    context.go('/result/$sessionId');
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
      ),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({required this.state, required this.strings});

  final TestState state;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final progress =
        ((state.answeredQuestionCount + 1) / (state.answeredQuestionCount + 2))
            .clamp(0.08, 0.92);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                strings.questionNumber(state.answeredQuestionCount + 1),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            _ScorePill(score: state.correctAnswerCount, strings: strings),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 9,
            value: progress,
            backgroundColor: AppColors.cardSecondary,
            color: AppColors.success,
          ),
        ),
      ],
    );
  }
}

class _AnswerGrid extends StatelessWidget {
  const _AnswerGrid({
    required this.answers,
    required this.selectedAnswer,
    required this.isLocked,
    required this.lastAnswerCorrect,
    required this.onTap,
  });

  final List<String> answers;
  final String? selectedAnswer;
  final bool isLocked;
  final bool? lastAnswerCorrect;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: answers.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        mainAxisExtent: 100,
      ),
      itemBuilder: (context, index) {
        final answer = answers[index];
        return _AnswerOptionCard(
          answer: answer,
          isSelected: selectedAnswer == answer,
          isLocked: isLocked,
          lastAnswerCorrect: lastAnswerCorrect,
          onTap: () => onTap(answer),
        );
      },
    );
  }
}

class _AnswerOptionCard extends StatelessWidget {
  const _AnswerOptionCard({
    required this.answer,
    required this.isSelected,
    required this.isLocked,
    required this.lastAnswerCorrect,
    required this.onTap,
  });

  final String answer;
  final bool isSelected;
  final bool isLocked;
  final bool? lastAnswerCorrect;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = _resolveAnswerColor(
      isSelected: isSelected,
      isCorrect: lastAnswerCorrect,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: isLocked ? null : onTap,
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colors.border,
              width: isSelected ? 2 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.shadow,
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Text(
              answer,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: colors.text),
            ),
          ),
        ),
      ),
    );
  }

  _AnswerColors _resolveAnswerColor({
    required bool isSelected,
    required bool? isCorrect,
  }) {
    if (!isSelected) {
      return _AnswerColors(
        background: Colors.white,
        border: AppColors.border,
        text: AppColors.textDark,
        shadow: AppColors.textDark.withValues(alpha: 0.04),
      );
    }

    if (isCorrect == true) {
      return const _AnswerColors(
        background: AppColors.successSurface,
        border: AppColors.success,
        text: AppColors.successDark,
        shadow: Color(0x1622C55E),
      );
    }

    if (isCorrect == false) {
      return const _AnswerColors(
        background: AppColors.errorSurface,
        border: AppColors.error,
        text: AppColors.errorDark,
        shadow: Color(0x14EF4444),
      );
    }

    return _AnswerColors(
      background: AppColors.background,
      border: AppColors.textDark,
      text: AppColors.textDark,
      shadow: AppColors.textDark.withValues(alpha: 0.06),
    );
  }
}

class _AnswerFeedbackChip extends StatelessWidget {
  const _AnswerFeedbackChip({required this.isCorrect, required this.strings});

  final bool isCorrect;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final background = isCorrect
        ? AppColors.successSurface
        : AppColors.errorSurface;
    final border = isCorrect ? AppColors.success : AppColors.error;
    final textColor = isCorrect ? AppColors.successDark : AppColors.errorDark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border.withValues(alpha: 0.55)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCorrect ? Icons.check_circle_rounded : Icons.close_rounded,
            color: textColor,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            isCorrect ? strings.correct : strings.incorrect,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: textColor),
          ),
        ],
      ),
    );
  }
}

class _ScorePill extends StatelessWidget {
  const _ScorePill({required this.score, required this.strings});

  final int score;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        strings.score(score),
        style: Theme.of(
          context,
        ).textTheme.labelMedium?.copyWith(color: AppColors.textDark),
      ),
    );
  }
}

class _AnswerColors {
  const _AnswerColors({
    required this.background,
    required this.border,
    required this.text,
    required this.shadow,
  });

  final Color background;
  final Color border;
  final Color text;
  final Color shadow;
}
