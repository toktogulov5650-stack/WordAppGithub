import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/language/language_provider.dart';
import '../../../core/network/api_exception.dart';
import '../data/test_api.dart';
import '../data/test_models.dart';

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
  return ref.read(testProvider.notifier).finishTest(testSessionId);
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

      state = state.copyWith(
        correctAnswerCount: response.correctAnswerCount,
        answeredQuestionCount: state.answeredQuestionCount + 1,
        lastAnswerCorrect: response.isCorrect,
      );

      await Future<void>.delayed(const Duration(milliseconds: 650));

      if (response.isFinished) {
        state = state.copyWith(isLocked: false);
        return sessionId;
      }

      state = state.copyWith(
        currentQuestion: response.currentQuestion,
        isLocked: false,
        isMarkedUnknown: false,
        clearSelectedAnswer: true,
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
}
