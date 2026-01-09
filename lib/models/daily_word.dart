class DailyWord {
  final int id;
  final String date; // YYYYMMDD
  final String title;
  final String description;
  final String imageUrl;
  final DateTime updatedAt;
  final DateTime dateTimestamp;

  DailyWord({
    required this.id,
    required this.date,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.updatedAt,
    required this.dateTimestamp,
  });

  /// 🔥 여기 추가
  DailyWord copyWith({
    int? id,
    String? date,
    String? title,
    String? description,
    String? imageUrl,
    DateTime? updatedAt,
    DateTime? dateTimestamp,
  }) {
    return DailyWord(
      id: id ?? this.id,
      date: date ?? this.date,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      updatedAt: updatedAt ?? this.updatedAt,
      dateTimestamp: dateTimestamp ?? this.dateTimestamp,
    );
  }

  factory DailyWord.fromMap(Map<String, dynamic> map) {
    return DailyWord(
      id: map['id'] as int,
      date: map['date'],
      title: map['title'],
      description: map['description'],
      imageUrl: map['image_url'],
      updatedAt: DateTime.parse(map['updated_at']),
      dateTimestamp: DateTime.parse(map['date_timestamp']),
    );
  }
}
