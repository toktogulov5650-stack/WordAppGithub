import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/language/app_strings.dart';
import '../../../core/language/language_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/empty_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../data/flashcard_model.dart';
import '../providers/flashcard_provider.dart';

class FlashcardsScreen extends ConsumerStatefulWidget {
  const FlashcardsScreen({super.key});

  @override
  ConsumerState<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends ConsumerState<FlashcardsScreen> {
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) {
      return;
    }
    _loaded = true;
    Future.microtask(() => ref.read(flashcardProvider.notifier).loadInitial());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(flashcardProvider);
    final strings = AppStrings.fromCode(
      ref.watch(languageProvider).languageCode,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                Responsive.horizontalPadding(context),
                Responsive.verticalGap(context, 24),
                Responsive.horizontalPadding(context),
                12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _FlashcardsHeader(title: strings.flashcards),
                  SizedBox(height: Responsive.verticalGap(context, 22)),
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        if (state.isLoading && state.card == null) {
                          return LoadingView(message: strings.flashcardLoading);
                        }

                        if (state.isEmpty) {
                          return EmptyView(title: strings.noFlashcards);
                        }

                        if (state.errorMessage != null && state.card == null) {
                          return ErrorView(
                            title: strings.flashcardLoadFailed,
                            message: state.errorMessage,
                            onRetry: () => ref
                                .read(flashcardProvider.notifier)
                                .loadInitial(),
                          );
                        }

                        final card = state.card;
                        if (card == null) {
                          return EmptyView(title: strings.noFlashcards);
                        }

                        return Column(
                          children: [
                            Expanded(
                              child: Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 480,
                                  ),
                                  child: GestureDetector(
                                    onTap: () => ref
                                        .read(flashcardProvider.notifier)
                                        .toggleReveal(),
                                    child: _AnimatedFlashcard(
                                      card: card,
                                      isRevealed: state.isRevealed,
                                      strings: strings,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 480,
                                ),
                                child: _NextCardButton(
                                  label: strings.nextFlashcard,
                                  isLoading:
                                      state.isLoading && state.card != null,
                                  onPressed: state.isLoading
                                      ? null
                                      : () => ref
                                            .read(flashcardProvider.notifier)
                                            .nextCard(),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FlashcardsHeader extends StatelessWidget {
  const _FlashcardsHeader({required this.title});

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

class _AnimatedFlashcard extends StatelessWidget {
  const _AnimatedFlashcard({
    required this.card,
    required this.isRevealed,
    required this.strings,
  });

  final FlashcardModel card;
  final bool isRevealed;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: isRevealed ? 1 : 0),
      duration: const Duration(milliseconds: 460),
      curve: Curves.easeInOutCubic,
      builder: (context, value, child) {
        final angle = value * math.pi;
        final isFront = value < 0.5;

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0012)
            ..rotateY(angle),
          child: isFront
              ? _FlashcardFace.front(card: card, strings: strings)
              : Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY(math.pi),
                  child: _FlashcardFace.back(card: card, strings: strings),
                ),
        );
      },
    );
  }
}

class _FlashcardFace extends StatelessWidget {
  const _FlashcardFace.front({required this.card, required this.strings})
    : isFront = true;

  const _FlashcardFace.back({required this.card, required this.strings})
    : isFront = false;

  final FlashcardModel card;
  final AppStrings strings;
  final bool isFront;

  @override
  Widget build(BuildContext context) {
    final cardHeight = (Responsive.screenHeight(context) * 0.53).clamp(
      340.0,
      500.0,
    );
    final label = isFront ? strings.english : strings.currentLanguageName;
    final translation = card.translations.join(', ').trim();
    final text = isFront
        ? card.englishWord
        : (translation.isEmpty ? '-' : translation);

    return Container(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFF1F1F3)),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 22,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: cardHeight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _LanguageBadge(label: label, isFront: isFront),
                const Spacer(),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.cardSecondary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.touch_app_outlined,
                    size: 17,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  maxLines: isFront ? 2 : 5,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontSize: Responsive.font(
                      context,
                      isFront ? 42 : 34,
                      minScale: 0.82,
                      maxScale: 1,
                    ),
                    height: isFront ? 1.1 : 1.2,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class _LanguageBadge extends StatelessWidget {
  const _LanguageBadge({required this.label, required this.isFront});

  final String label;
  final bool isFront;

  @override
  Widget build(BuildContext context) {
    final color = isFront ? AppColors.actionBlue : AppColors.success;

    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 11),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Center(
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: color,
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

class _NextCardButton extends StatelessWidget {
  const _NextCardButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: isLoading ? null : onPressed,
        child: Ink(
          height: 54,
          decoration: BoxDecoration(
            color: AppColors.textDark,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
