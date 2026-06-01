import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/translation_history.dart';

class HistoryService {
  static final HistoryService _instance = HistoryService._internal();
  factory HistoryService() => _instance;
  HistoryService._internal();

  static const String _historyKey = 'translation_history';
  List<TranslationHistory> _history = [];

  List<TranslationHistory> get history => List.unmodifiable(_history);
  List<TranslationHistory> get favorites =>
      _history.where((h) => h.isFavorite).toList();

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_historyKey);
    if (raw != null) {
      final List decoded = jsonDecode(raw);
      _history = decoded.map((e) => TranslationHistory.fromJson(e)).toList();
    }
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_history.map((h) => h.toJson()).toList());
    await prefs.setString(_historyKey, encoded);
  }

  Future<void> add(TranslationHistory item) async {
    // Avoid duplicates
    _history.removeWhere((h) =>
        h.sourceText == item.sourceText &&
        h.sourceLang == item.sourceLang &&
        h.targetLang == item.targetLang);
    _history.insert(0, item);
    if (_history.length > 100) _history = _history.sublist(0, 100);
    await save();
  }

  Future<void> toggleFavorite(String id) async {
    final idx = _history.indexWhere((h) => h.id == id);
    if (idx != -1) {
      _history[idx].isFavorite = !_history[idx].isFavorite;
      await save();
    }
  }

  Future<void> delete(String id) async {
    _history.removeWhere((h) => h.id == id);
    await save();
  }

  Future<void> clearAll() async {
    _history.clear();
    await save();
  }
}
