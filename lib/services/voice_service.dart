import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceService {
  static final VoiceService _instance = VoiceService._internal();
  factory VoiceService() => _instance;
  VoiceService._internal();

  final FlutterTts _tts = FlutterTts();
  final stt.SpeechToText _stt = stt.SpeechToText();

  bool _isSpeaking = false;
  bool _isListening = false;
  bool _sttInitialized = false;

  bool get isSpeaking => _isSpeaking;
  bool get isListening => _isListening;

  // ──────────────── TTS ────────────────

  Future<void> initTts() async {
    await _tts.setVolume(1.0);
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.0);

    _tts.setStartHandler(() => _isSpeaking = true);
    _tts.setCompletionHandler(() => _isSpeaking = false);
    _tts.setErrorHandler((_) => _isSpeaking = false);
  }

  Future<void> speak(String text, String languageCode) async {
    if (text.isEmpty) return;
    await stop();

    String ttsLang = _mapToTtsLanguage(languageCode);
    await _tts.setLanguage(ttsLang);
    await _tts.speak(text);
    _isSpeaking = true;
  }

  Future<void> stop() async {
    await _tts.stop();
    _isSpeaking = false;
  }

  String _mapToTtsLanguage(String code) {
    const map = {
      'en': 'en-US',
      'es': 'es-ES',
      'fr': 'fr-FR',
      'de': 'de-DE',
      'it': 'it-IT',
      'pt': 'pt-BR',
      'ru': 'ru-RU',
      'ja': 'ja-JP',
      'ko': 'ko-KR',
      'zh-cn': 'zh-CN',
      'ar': 'ar-SA',
      'hi': 'hi-IN',
      'tr': 'tr-TR',
      'nl': 'nl-NL',
      'pl': 'pl-PL',
      'sv': 'sv-SE',
      'ur': 'ur-PK',
    };
    return map[code] ?? 'en-US';
  }

  // ──────────────── STT ────────────────

  Future<bool> initStt() async {
    if (_sttInitialized) return true;
    _sttInitialized = await _stt.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          _isListening = false;
        }
      },
      onError: (error) => _isListening = false,
    );
    return _sttInitialized;
  }

  Future<void> startListening({
    required String languageCode,
    required Function(String text, bool isFinal) onResult,
  }) async {
    if (!_sttInitialized) {
      final ok = await initStt();
      if (!ok) return;
    }

    String locale = _mapToSttLocale(languageCode);

    await _stt.listen(
      onResult: (result) {
        onResult(result.recognizedWords, result.finalResult);
      },
      localeId: locale,
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
    );
    _isListening = true;
  }

  Future<void> stopListening() async {
    await _stt.stop();
    _isListening = false;
  }

  bool get sttAvailable => _sttInitialized;

  String _mapToSttLocale(String code) {
    const map = {
      'en': 'en_US',
      'es': 'es_ES',
      'fr': 'fr_FR',
      'de': 'de_DE',
      'it': 'it_IT',
      'pt': 'pt_BR',
      'ru': 'ru_RU',
      'ja': 'ja_JP',
      'ko': 'ko_KR',
      'zh-cn': 'zh_CN',
      'ar': 'ar_SA',
      'hi': 'hi_IN',
      'tr': 'tr_TR',
      'nl': 'nl_NL',
      'ur': 'ur_PK',
    };
    return map[code] ?? 'en_US';
  }
}
