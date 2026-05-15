import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/language/language_provider.dart';
import '../../../core/network/api_exception.dart';
import '../data/flashcard_api.dart';
import '../data/flashcard_model.dart';

class FlashcardState {
  const FlashcardState({
    this.isLoading = false,
    this.card,
    this.isRevealed = false,
    this.errorMessage,
    this.isEmpty = false,
  });

  final bool isLoading;
  final FlashcardModel? card;
  final bool isRevealed;
  final String? errorMessage;
  final bool isEmpty;

  FlashcardState copyWith({
    bool? isLoading,
    FlashcardModel? card,
    bool clearCard = false,
    bool? isRevealed,
    String? errorMessage,
    bool clearError = false,
    bool? isEmpty,
  }) {
    return FlashcardState(
      isLoading: isLoading ?? this.isLoading,
      card: clearCard ? null : (card ?? this.card),
      isRevealed: isRevealed ?? this.isRevealed,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isEmpty: isEmpty ?? this.isEmpty,
    );
  }
}

final flashcardProvider = NotifierProvider<FlashcardNotifier, FlashcardState>(
  FlashcardNotifier.new,
);

class FlashcardNotifier extends Notifier<FlashcardState> {
  @override
  FlashcardState build() {
    ref.listen<LanguageState>(languageProvider, (previous, next) {
      if (previous?.languageCode != next.languageCode &&
          next.languageCode != null) {
        state = const FlashcardState();
        Future.microtask(loadInitial);
      }
    });
    return const FlashcardState();
  }

  Future<void> loadInitial() async {
    await _load();
  }

  Future<void> nextCard() async {
    await _load(excludeWordId: state.card?.wordId);
  }

  void reveal() {
    state = state.copyWith(isRevealed: true);
  }

  void toggleReveal() {
    state = state.copyWith(isRevealed: !state.isRevealed);
  }

  Future<void> _load({int? excludeWordId}) async {
    state = state.copyWith(
      isLoading: true,
      isRevealed: false,
      clearError: true,
      isEmpty: false,
    );

    try {
      final card = await ref
          .read(flashcardApiProvider)
          .getRandomFlashcard(
            excludeWordId: excludeWordId,
            languageCode: ref.read(languageProvider).languageCode,
          );
      state = state.copyWith(isLoading: false, card: card, isRevealed: false);
    } on ApiException catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.isNotFound ? null : error.message,
        isEmpty: error.isNotFound,
        clearCard: error.isNotFound,
      );
    }
  }
}
