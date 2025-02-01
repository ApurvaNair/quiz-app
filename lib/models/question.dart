class Question {
  final String question;
  final List<String> options;
  final String correctAnswer;

  Question({
    required this.question,
    required this.options,
    required this.correctAnswer,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    List<String> options = (json['options'] as List<dynamic>)
        .map((option) => option['description'] as String)
        .toList();

    // Correct Answer extraction
    String correctAnswer = options.firstWhere(
      (option) =>
          json['options'].firstWhere(
              (opt) => opt['description'] == option)['is_correct'] ==
          true,
      orElse: () => '',
    );

    return Question(
      question: json['description'] as String,
      options: options,
      correctAnswer: correctAnswer,
    );
  }
}
