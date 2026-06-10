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
    this.correctAnswer,
    this.currentQuestion,
  });

  final bool isCorrect;
  final int correctAnswerCount;
  final bool isFinished;
  final String? correctAnswer;
  final TestQuestionModel? currentQuestion;

  factory SubmitAnswerResponse.fromJson(Map<String, dynamic> json) {
    return SubmitAnswerResponse(
      isCorrect: json['isCorrect'] as bool? ?? false,
      correctAnswerCount: (json['correctAnswerCount'] as num?)?.toInt() ?? 0,
      isFinished: json['isFinished'] as bool? ?? false,
      correctAnswer: _readCorrectAnswer(json),
      currentQuestion: json['currentQuestion'] is Map<String, dynamic>
          ? TestQuestionModel.fromJson(
              json['currentQuestion'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  static String? _readCorrectAnswer(Map<String, dynamic> json) {
    for (final key in const [
      'correctAnswer',
      'correct_answer',
      'correctAnswerText',
      'correctTranslation',
      'correct_translation',
      'rightAnswer',
      'right_answer',
      'correctOption',
      'correct_option',
      'correctTranslations',
      'correct_translations',
      'answer',
      'translation',
    ]) {
      final value = _stringFromValue(json[key]);
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }

    return null;
  }

  static String? _stringFromValue(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is String) {
      final text = value.trim();
      return text.isEmpty ? null : text;
    }
    if (value is Iterable) {
      final text = value
          .map(_stringFromValue)
          .whereType<String>()
          .where((item) => item.isNotEmpty)
          .join(', ');
      return text.isEmpty ? null : text;
    }
    if (value is Map<String, dynamic>) {
      for (final key in const [
        'translation',
        'text',
        'answer',
        'value',
        'name',
        'primaryTranslation',
      ]) {
        final text = _stringFromValue(value[key]);
        if (text != null && text.isNotEmpty) {
          return text;
        }
      }
    }

    final text = value.toString().trim();
    return text.isEmpty ? null : text;
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
