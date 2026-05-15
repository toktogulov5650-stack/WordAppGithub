import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/language/app_strings.dart';
import '../../../core/language/language_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../core/widgets/section_title.dart';
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
    final strings = AppStrings.fromCode(ref.watch(languageProvider).languageCode);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SectionTitle(title: strings.flashcards),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        if (state.isLoading && state.card == null) {
                          return LoadingView(
                            message: strings.flashcardLoading,
                          );
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
                                    maxWidth: 460,
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
                            AppButton(
                              label: strings.nextFlashcard,
                              icon: Icons.arrow_forward_rounded,
                              isLoading: state.isLoading && state.card != null,
                              onPressed: state.isLoading
                                  ? null
                                  : () => ref
                                        .read(flashcardProvider.notifier)
                                        .nextCard(),
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
    final label = isFront ? strings.english : strings.currentLanguageName;
    final text = isFront ? card.englishWord : card.translations.join(', ');

    return AppCard(
      radius: 32,
      backgroundColor: Colors.white,
      padding: const EdgeInsets.all(28),
      child: SizedBox(
        width: double.infinity,
        height: 430,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _LanguageBadge(label: label),
            const Spacer(),
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontSize: isFront ? 44 : 36,
                    color: AppColors.textDark,
                    letterSpacing: -0.8,
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
  const _LanguageBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelMedium?.copyWith(color: AppColors.textMuted),
      ),
    );
  }
}
