class TranslationHistory {
  final String id;
  final String sourceText;
  final String translatedText;
  final String sourceLang;
  final String targetLang;
  final DateTime timestamp;
  bool isFavorite;

  TranslationHistory({
    required this.id,
    required this.sourceText,
    required this.translatedText,
    required this.sourceLang,
    required this.targetLang,
    required this.timestamp,
    this.isFavorite = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'sourceText': sourceText,
        'translatedText': translatedText,
        'sourceLang': sourceLang,
        'targetLang': targetLang,
        'timestamp': timestamp.toIso8601String(),
        'isFavorite': isFavorite,
      };

  factory TranslationHistory.fromJson(Map<String, dynamic> json) =>
      TranslationHistory(
        id: json['id'],
        sourceText: json['sourceText'],
        translatedText: json['translatedText'],
        sourceLang: json['sourceLang'],
        targetLang: json['targetLang'],
        timestamp: DateTime.parse(json['timestamp']),
        isFavorite: json['isFavorite'] ?? false,
      );
}
