class DailyQuizModel {
  final int? id; // DB에서 identity 쓰면 있음(없어도 됨)
  final String date; // yyyymmdd
  final String question;
  final String answer;
  final String? explanation;
  final String? updatedAt;
  final String? dateTimestamp;

  DailyQuizModel({
    this.id,
    required this.date,
    required this.question,
    required this.answer,
    this.explanation,
    this.updatedAt,
    this.dateTimestamp,
  });

  factory DailyQuizModel.fromJson(Map<String, dynamic> json) {
    return DailyQuizModel(
      id: json['id'] is int ? json['id'] : null,
      date: (json['date'] ?? '').toString(),
      question: (json['question'] ?? '').toString(),
      answer: (json['answer'] ?? '').toString(),
      explanation: json['explanation']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      dateTimestamp: json['date_timestamp']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'date': date,
      'question': question,
      'answer': answer,
      'explanation': explanation,
      'updated_at': updatedAt,
      'date_timestamp': dateTimestamp,
    };
  }

  DailyQuizModel copyWith({
    int? id,
    String? date,
    String? question,
    String? answer,
    String? explanation,
    String? updatedAt,
    String? dateTimestamp,
  }) {
    return DailyQuizModel(
      id: id ?? this.id,
      date: date ?? this.date,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      explanation: explanation ?? this.explanation,
      updatedAt: updatedAt ?? this.updatedAt,
      dateTimestamp: dateTimestamp ?? this.dateTimestamp,
    );
  }
}
