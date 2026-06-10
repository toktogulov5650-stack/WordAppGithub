import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/language/language_provider.dart';
import '../../../core/network/api_exception.dart';
import '../../explanations/data/word_explanation_api.dart';
import '../data/test_api.dart';
import '../data/test_models.dart';
import 'records_provider.dart';

class TestState {
  const TestState({
    this.isLoading = false,
    this.isLocked = false,
    this.currentCategoryId,
    this.testSessionId,
    this.currentQuestion,
    this.correctAnswerCount = 0,
    this.answeredQuestionCount = 0,
    this.isMarkedUnknown = false,
    this.selectedAnswer,
    this.correctAnswer,
    this.lastAnswerCorrect,
    this.errorMessage,
  });

  final bool isLoading;
  final bool isLocked;
  final int? currentCategoryId;
  final int? testSessionId;
  final TestQuestionModel? currentQuestion;
  final int correctAnswerCount;
  final int answeredQuestionCount;
  final bool isMarkedUnknown;
  final String? selectedAnswer;
  final String? correctAnswer;
  final bool? lastAnswerCorrect;
  final String? errorMessage;

  TestState copyWith({
    bool? isLoading,
    bool? isLocked,
    int? currentCategoryId,
    bool clearCurrentCategoryId = false,
    int? testSessionId,
    bool clearSessionId = false,
    TestQuestionModel? currentQuestion,
    bool clearQuestion = false,
    int? correctAnswerCount,
    int? answeredQuestionCount,
    bool? isMarkedUnknown,
    String? selectedAnswer,
    bool clearSelectedAnswer = false,
    String? correctAnswer,
    bool clearCorrectAnswer = false,
    bool? lastAnswerCorrect,
    bool clearLastAnswerCorrect = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TestState(
      isLoading: isLoading ?? this.isLoading,
      isLocked: isLocked ?? this.isLocked,
      currentCategoryId: clearCurrentCategoryId
          ? null
          : (currentCategoryId ?? this.currentCategoryId),
      testSessionId: clearSessionId
          ? null
          : (testSessionId ?? this.testSessionId),
      currentQuestion: clearQuestion
          ? null
          : (currentQuestion ?? this.currentQuestion),
      correctAnswerCount: correctAnswerCount ?? this.correctAnswerCount,
      answeredQuestionCount:
          answeredQuestionCount ?? this.answeredQuestionCount,
      isMarkedUnknown: isMarkedUnknown ?? this.isMarkedUnknown,
      selectedAnswer: clearSelectedAnswer
          ? null
          : (selectedAnswer ?? this.selectedAnswer),
      correctAnswer: clearCorrectAnswer
          ? null
          : (correctAnswer ?? this.correctAnswer),
      lastAnswerCorrect: clearLastAnswerCorrect
          ? null
          : (lastAnswerCorrect ?? this.lastAnswerCorrect),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  factory TestState.initial() => const TestState();
}

final testProvider = NotifierProvider<TestNotifier, TestState>(
  TestNotifier.new,
);

final finishTestProvider = FutureProvider.family<FinishTestResponse, int>((
  ref,
  testSessionId,
) async {
  final result = await ref
      .read(testProvider.notifier)
      .finishTest(testSessionId);
  ref.invalidate(recordsProvider);
  return result;
});

class TestNotifier extends Notifier<TestState> {
  @override
  TestState build() => TestState.initial();

  Future<void> startTest(int categoryId) async {
    state = TestState.initial().copyWith(
      isLoading: true,
      currentCategoryId: categoryId,
    );
    try {
      final response = await ref
          .read(testApiProvider)
          .startTest(
            StartTestRequest(
              categoryId: categoryId,
              languageCode: ref.read(languageProvider).languageCode ?? '',
            ),
          );
      state = TestState(
        currentCategoryId: categoryId,
        testSessionId: response.testSessionId,
        currentQuestion: response.currentQuestion,
      );
    } on ApiException catch (error) {
      state = TestState.initial().copyWith(
        currentCategoryId: categoryId,
        errorMessage: error.message,
      );
    }
  }

  void setMarkedUnknown(bool value) {
    state = state.copyWith(isMarkedUnknown: value);
  }

  Future<int?> submitUnknownAnswer() async {
    final question = state.currentQuestion;
    if (question == null || question.answerOptions.isEmpty || state.isLocked) {
      return null;
    }

    state = state.copyWith(isMarkedUnknown: true);
    return submitAnswer(question.answerOptions.first);
  }

  Future<int?> submitAnswer(String selectedAnswer) async {
    final question = state.currentQuestion;
    final sessionId = state.testSessionId;
    if (question == null || sessionId == null || state.isLocked) {
      return null;
    }

    state = state.copyWith(
      isLocked: true,
      selectedAnswer: selectedAnswer,
      clearError: true,
      clearCorrectAnswer: true,
      clearLastAnswerCorrect: true,
    );

    try {
      final response = await ref
          .read(testApiProvider)
          .submitAnswer(
            SubmitAnswerRequest(
              testSessionId: sessionId,
              wordId: question.wordId,
              selectedAnswer: selectedAnswer,
              isMarkedUnknown: state.isMarkedUnknown,
            ),
          );
      final correctAnswer = await _resolveCorrectAnswer(response, question);

      state = state.copyWith(
        correctAnswerCount: response.correctAnswerCount,
        answeredQuestionCount: state.answeredQuestionCount + 1,
        correctAnswer: correctAnswer,
        lastAnswerCorrect: response.isCorrect,
      );

      await Future<void>.delayed(const Duration(milliseconds: 1100));

      if (response.isFinished) {
        state = state.copyWith(isLocked: false);
        return sessionId;
      }

      state = state.copyWith(
        currentQuestion: response.currentQuestion,
        isLocked: false,
        isMarkedUnknown: false,
        clearSelectedAnswer: true,
        clearCorrectAnswer: true,
        clearLastAnswerCorrect: true,
      );
      return null;
    } on ApiException catch (error) {
      state = state.copyWith(isLocked: false, errorMessage: error.message);
      return null;
    }
  }

  Future<FinishTestResponse> finishTest(int testSessionId) async {
    return ref.read(testApiProvider).finishTest(testSessionId);
  }

  void clear() {
    state = TestState.initial();
  }

  Future<String?> _resolveCorrectAnswer(
    SubmitAnswerResponse response,
    TestQuestionModel question,
  ) async {
    final directAnswer = _matchAnswerOption(
      response.correctAnswer,
      question.answerOptions,
    );
    if (directAnswer != null) {
      return directAnswer;
    }

    if (response.correctAnswer != null &&
        response.correctAnswer!.trim().isNotEmpty) {
      return response.correctAnswer;
    }

    if (response.isCorrect) {
      return null;
    }

    try {
      final explanation = await ref
          .read(wordExplanationApiProvider)
          .getWordExplanation(
            question.wordId,
            languageCode: ref.read(languageProvider).languageCode,
          );

      return _matchAnswerOption(
            explanation.translations,
            question.answerOptions,
          ) ??
          explanation.translations;
    } on ApiException {
      return null;
    }
  }

  String? _matchAnswerOption(String? source, List<String> options) {
    if (source == null || source.trim().isEmpty) {
      return null;
    }

    for (final option in options) {
      if (_answersMatch(option, source)) {
        return option;
      }
    }

    return null;
  }

  bool _answersMatch(String left, String right) {
    final leftParts = _answerParts(left);
    final rightParts = _answerParts(right);

    return leftParts.any(rightParts.contains);
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
