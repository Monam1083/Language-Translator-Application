import 'package:translator/translator.dart';

class TranslationService {
  static final TranslationService _instance = TranslationService._internal();
  factory TranslationService() => _instance;
  TranslationService._internal();

  final GoogleTranslator _translator = GoogleTranslator();

  Future<String> translate({
    required String text,
    required String from,
    required String to,
  }) async {
    if (text.trim().isEmpty) return '';

    try {
      final translation = await _translator.translate(
        text,
        from: from,
        to: to,
      );
      return translation.text;
    } catch (e) {
      throw Exception('Translation failed: ${e.toString()}');
    }
  }

  Future<String> detectLanguage(String text) async {
    try {
      final translation = await _translator.translate(text, to: 'en');
      return translation.sourceLanguage.code;
    } catch (e) {
      return 'auto';
    }
  }
}
