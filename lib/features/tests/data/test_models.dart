class StartTestRequest {
  const StartTestRequest({
    required this.categoryId,
    required this.languageCode,
  });

  final int categoryId;
  final String languageCode;

  Map<String, dynamic> toJson() {
    return {'categoryId': categoryId, 'languageCode': languageCode};
  }
}

class TestQuestionModel {
  const TestQuestionModel({
    required this.wordId,
    required this.englishWord,
    required this.answerOptions,
  });

  final int wordId;
  final String englishWord;
  final List<String> answerOptions;

  factory TestQuestionModel.fromJson(Map<String, dynamic> json) {
    final options = json['answerOptions'] as List<dynamic>? ?? const [];
    return TestQuestionModel(
      wordId: (json['wordId'] as num?)?.toInt() ?? 0,
      englishWord: (json['englishWord'] as String?) ?? '',
      answerOptions: options.map((item) => item.toString()).toList(),
    );
  }
}

class StartTestResponse {
  const StartTestResponse({
    required this.testSessionId,
    required this.currentQuestion,
  });

  final int testSessionId;
  final TestQuestionModel currentQuestion;

  factory StartTestResponse.fromJson(Map<String, dynamic> json) {
    return StartTestResponse(
      testSessionId: (json['testSessionId'] as num?)?.toInt() ?? 0,
      currentQuestion: TestQuestionModel.fromJson(
        (json['currentQuestion'] as Map<String, dynamic>?) ?? const {},
      ),
    );
  }
}

class SubmitAnswerRequest {
  const SubmitAnswerRequest({
    required this.testSessionId,
    required this.wordId,
    required this.selectedAnswer,
    required this.isMarkedUnknown,
  });

  final int testSessionId;
  final int wordId;
  final String selectedAnswer;
  final bool isMarkedUnknown;

  Map<String, dynamic> toJson() {
    return {
      'testSessionId': testSessionId,
      'wordId': wordId,
      'selectedAnswer': selectedAnswer,
      'isMarkedUnknown': isMarkedUnknown,
    };
  }
}

class SubmitAnswerResponse {
  const SubmitAnswerResponse({
    required this.isCorrect,
    required this.correctAnswerCount,
    required this.isFinished,
    this.currentQuestion,
  });

  final bool isCorrect;
  final int correctAnswerCount;
  final bool isFinished;
  final TestQuestionModel? currentQuestion;

  factory SubmitAnswerResponse.fromJson(Map<String, dynamic> json) {
    return SubmitAnswerResponse(
      isCorrect: json['isCorrect'] as bool? ?? false,
      correctAnswerCount: (json['correctAnswerCount'] as num?)?.toInt() ?? 0,
      isFinished: json['isFinished'] as bool? ?? false,
      currentQuestion: json['currentQuestion'] is Map<String, dynamic>
          ? TestQuestionModel.fromJson(
              json['currentQuestion'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

class FinishTestResponse {
  const FinishTestResponse({
    required this.correctAnswerCount,
    required this.bestScore,
  });

  final int correctAnswerCount;
  final int bestScore;

  factory FinishTestResponse.fromJson(Map<String, dynamic> json) {
    return FinishTestResponse(
      correctAnswerCount: (json['correctAnswerCount'] as num?)?.toInt() ?? 0,
      bestScore: (json['bestScore'] as num?)?.toInt() ?? 0,
    );
  }
}
