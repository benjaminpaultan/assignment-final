class MoodEntry {
  final int? id;
  final String date;
  final String emoji;
  final String note;
  final String? imagePath;

  MoodEntry({
    this.id,
    required this.date,
    required this.emoji,
    required this.note,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'emoji': emoji,
      'note': note,
      'imagePath': imagePath,
    };
  }

  factory MoodEntry.fromMap(Map<String, dynamic> map) {
    return MoodEntry(
      id: map['id'],
      date: map['date'],
      emoji: map['emoji'],
      note: map['note'],
      imagePath: map['imagePath'],
    );
  }

  MoodEntry copyWith({
    int? id,
    String? date,
    String? emoji,
    String? note,
    String? imagePath,
  }) {
    return MoodEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      emoji: emoji ?? this.emoji,
      note: note ?? this.note,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}