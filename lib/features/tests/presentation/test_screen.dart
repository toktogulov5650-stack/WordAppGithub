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
      final errorMessage = next.errorMessage;
      if (errorMessage != null &&
          errorMessage != previous?.errorMessage &&
          mounted &&
          next.currentQuestion != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
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
            padding: EdgeInsets.fromLTRB(
              Responsive.horizontalPadding(
                context,
                compact: 18,
                regular: 20,
                wide: 24,
              ),
              8,
              Responsive.horizontalPadding(
                context,
                compact: 18,
                regular: 20,
                wide: 24,
              ),
              20,
            ),
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
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final answerGrid = _AnswerGrid(
                          answers: question.answerOptions,
                          selectedAnswer: state.selectedAnswer,
                          correctAnswer: state.correctAnswer,
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
                        );
                        final unknownButton = _UnknownButton(
                          label: state.isMarkedUnknown
                              ? strings.markedUnknown
                              : strings.dontKnow,
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
                        );
                        final lastAnswerCorrect = state.lastAnswerCorrect;
                        final topContent = <Widget>[
                          _ProgressHeader(state: state, strings: strings),
                          if (lastAnswerCorrect != null) ...[
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: _AnswerFeedbackChip(
                                isCorrect: lastAnswerCorrect,
                                strings: strings,
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),
                          _QuestionPanel(
                            label: strings.englishWord,
                            word: question.englishWord,
                          ),
                        ];

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ...topContent,
                            const Spacer(),
                            answerGrid,
                            const SizedBox(height: 12),
                            unknownButton,
                          ],
                        );
                      },
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
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
              ),
            ),
            _ScorePill(score: state.correctAnswerCount, strings: strings),
          ],
        ),
        const SizedBox(height: 11),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 6,
            value: progress,
            backgroundColor: AppColors.cardSecondary,
            color: AppColors.success,
          ),
        ),
      ],
    );
  }
}

class _QuestionPanel extends StatelessWidget {
  const _QuestionPanel({required this.label, required this.word});

  final String label;
  final String word;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      child: Container(
        constraints: BoxConstraints(
          minHeight: Responsive.verticalGap(
            context,
            202,
            minScale: 0.84,
            maxScale: 1.06,
          ),
        ),
        padding: EdgeInsets.fromLTRB(
          Responsive.isCompact(context) ? 18 : 22,
          Responsive.isCompact(context) ? 24 : 28,
          Responsive.isCompact(context) ? 18 : 22,
          Responsive.isCompact(context) ? 26 : 30,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFFBFCFB),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFEFF2EF)),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowSoft,
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Text(
            word,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontSize: Responsive.font(context, 44, minScale: 0.82),
              height: 1.1,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
              letterSpacing: 0,
            ),
          ),
        ),
      ),
    );
  }
}

class _AnswerGrid extends StatelessWidget {
  const _AnswerGrid({
    required this.answers,
    required this.selectedAnswer,
    required this.correctAnswer,
    required this.isLocked,
    required this.lastAnswerCorrect,
    required this.onTap,
  });

  final List<String> answers;
  final String? selectedAnswer;
  final String? correctAnswer;
  final bool isLocked;
  final bool? lastAnswerCorrect;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 370;
        return GridView.builder(
          itemCount: answers.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: isCompact ? 10 : 12,
            mainAxisSpacing: isCompact ? 10 : 12,
            mainAxisExtent: isCompact ? 98 : 112,
          ),
          itemBuilder: (context, index) {
            final answer = answers[index];
            return _AnswerOptionCard(
              answer: answer,
              isSelected: selectedAnswer == answer,
              isCorrectAnswer: _sameAnswer(answer, correctAnswer),
              isLocked: isLocked,
              lastAnswerCorrect: lastAnswerCorrect,
              onTap: () => onTap(answer),
            );
          },
        );
      },
    );
  }

  bool _sameAnswer(String answer, String? correctAnswer) {
    if (correctAnswer == null || correctAnswer.trim().isEmpty) {
      return false;
    }

    final answerParts = _answerParts(answer);
    final correctParts = _answerParts(correctAnswer);

    return answerParts.any(correctParts.contains);
  }

  Set<String> _answerParts(String text) {
    final parts = <String>{};
    for (final rawPart in text.split(RegExp(r'[;,/\n|]+'))) {
      final normalized = _normalizeAnswer(rawPart);
      if (normalized.isNotEmpty) {
        parts.add(normalized);
      }

      final withoutClarification = rawPart.replaceAll(
        RegExp(r'\([^)]*\)|\[[^\]]*\]'),
        ' ',
      );
      final simplified = _normalizeAnswer(withoutClarification);
      if (simplified.isNotEmpty) {
        parts.add(simplified);
      }
    }

    return parts;
  }

  String _normalizeAnswer(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[.!?:"“”‘’«»]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}

class _AnswerOptionCard extends StatelessWidget {
  const _AnswerOptionCard({
    required this.answer,
    required this.isSelected,
    required this.isCorrectAnswer,
    required this.isLocked,
    required this.lastAnswerCorrect,
    required this.onTap,
  });

  final String answer;
  final bool isSelected;
  final bool isCorrectAnswer;
  final bool isLocked;
  final bool? lastAnswerCorrect;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = _resolveAnswerColor(
      isSelected: isSelected,
      isCorrectAnswer: isCorrectAnswer,
      isCorrect: lastAnswerCorrect,
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border, width: isSelected ? 1.6 : 1),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: isLocked ? null : onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Center(
              child: Text(
                answer,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colors.text,
                  fontSize: Responsive.font(context, 16, minScale: 0.90),
                  height: 1.25,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _AnswerColors _resolveAnswerColor({
    required bool isSelected,
    required bool isCorrectAnswer,
    required bool? isCorrect,
  }) {
    if (isCorrectAnswer && isCorrect == false) {
      return const _AnswerColors(
        background: Color(0xFFF1FFF6),
        border: Color(0xFF86EFAC),
        text: AppColors.successDark,
        shadow: Color(0x0D22C55E),
      );
    }

    if (!isSelected) {
      return _AnswerColors(
        background: Colors.white,
        border: const Color(0xFFF1F1F3),
        text: AppColors.textDark,
        shadow: AppColors.textDark.withValues(alpha: 0.025),
      );
    }

    if (isCorrect == true) {
      return const _AnswerColors(
        background: Color(0xFFF1FFF6),
        border: Color(0xFF86EFAC),
        text: AppColors.successDark,
        shadow: Color(0x0D22C55E),
      );
    }

    if (isCorrect == false) {
      return const _AnswerColors(
        background: Color(0xFFFFF1F2),
        border: Color(0xFFFCA5A5),
        text: AppColors.errorDark,
        shadow: Color(0x0DEF4444),
      );
    }

    return _AnswerColors(
      background: const Color(0xFFFAFAFB),
      border: AppColors.textDark,
      text: AppColors.textDark,
      shadow: AppColors.textDark.withValues(alpha: 0.035),
    );
  }
}

class _UnknownButton extends StatelessWidget {
  const _UnknownButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: isDisabled ? 0.55 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onPressed,
          child: Ink(
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.warningSurface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFFDE68A)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x08F59E0B),
                  blurRadius: 14,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.help_outline_rounded,
                  color: AppColors.warningDark,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.warningDark,
                      fontSize: Responsive.font(context, 14),
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
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: border.withValues(alpha: 0.35)),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardSecondary,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        strings.score(score),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: AppColors.textMuted,
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
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
