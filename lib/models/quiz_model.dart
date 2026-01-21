class DailyQuizModel {
  final int? id; // identity (optional)
  final String date; // yyyyMMdd
  final String question;
  final String answer;
  final String? explanation;
  final DateTime? updatedAt;
  final DateTime? dateTimestamp;

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
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      dateTimestamp: json['date_timestamp'] != null
          ? DateTime.tryParse(json['date_timestamp'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'date': date,
      'question': question,
      'answer': answer,
      'explanation': explanation,
      'updated_at': updatedAt?.toIso8601String(),
      'date_timestamp': dateTimestamp?.toIso8601String(),
    };
  }

  DailyQuizModel copyWith({
    int? id,
    String? date,
    String? question,
    String? answer,
    String? explanation,
    DateTime? updatedAt,
    DateTime? dateTimestamp,
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
