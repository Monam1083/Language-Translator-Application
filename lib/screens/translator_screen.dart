import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/language.dart';
import '../models/translation_history.dart';
import '../services/translation_service.dart';
import '../services/voice_service.dart';
import '../services/history_service.dart';
import '../widgets/language_picker_sheet.dart';
import '../widgets/voice_button.dart';
import 'history_screen.dart';

class TranslatorScreen extends StatefulWidget {
  const TranslatorScreen({super.key});

  @override
  State<TranslatorScreen> createState() => _TranslatorScreenState();
}

class _TranslatorScreenState extends State<TranslatorScreen>
    with TickerProviderStateMixin {
  final _translationService = TranslationService();
  final _voiceService = VoiceService();
  final _historyService = HistoryService();

  final _inputController = TextEditingController();
  final _inputFocus = FocusNode();
  final _scrollController = ScrollController();

  Language _sourceLang = Language.languages[0]; // English
  Language _targetLang = Language.languages[1]; // Spanish

  String _translatedText = '';
  String _statusMsg = '';
  bool _isTranslating = false;
  bool _isListening = false;
  bool _isSpeakingSource = false;
  bool _isSpeakingTarget = false;

  Timer? _debounce;

  late AnimationController _swapAnim;
  late AnimationController _micPulse;

  @override
  void initState() {
    super.initState();
    _swapAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _micPulse = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);

    _voiceService.initTts();
    _historyService.load().then((_) => setState(() {}));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _inputController.dispose();
    _inputFocus.dispose();
    _scrollController.dispose();
    _swapAnim.dispose();
    _micPulse.dispose();
    _voiceService.stop();
    _voiceService.stopListening();
    super.dispose();
  }

  // ─────────────── TRANSLATION ───────────────

  void _onTextChanged(String text) {
    _debounce?.cancel();
    if (text.trim().isEmpty) {
      setState(() {
        _translatedText = '';
        _statusMsg = '';
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 700), () => _translate());
  }

  Future<void> _translate() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isTranslating = true;
      _statusMsg = '';
    });

    try {
      final result = await _translationService.translate(
        text: text,
        from: _sourceLang.code,
        to: _targetLang.code,
      );
      if (!mounted) return;
      setState(() {
        _translatedText = result;
        _isTranslating = false;
      });
      // Save history
      await _historyService.add(TranslationHistory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sourceText: text,
        translatedText: result,
        sourceLang: _sourceLang.code,
        targetLang: _targetLang.code,
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isTranslating = false;
        _statusMsg = 'Translation failed. Check your connection.';
      });
    }
  }

  void _swapLanguages() async {
    if (_swapAnim.isAnimating) return;
    await _swapAnim.forward();
    setState(() {
      final tmp = _sourceLang;
      _sourceLang = _targetLang;
      _targetLang = tmp;
      final tmpTxt = _inputController.text;
      _inputController.text = _translatedText;
      _translatedText = tmpTxt;
    });
    _swapAnim.reverse();
    if (_inputController.text.isNotEmpty) _translate();
  }

  void _clearInput() {
    _inputController.clear();
    setState(() {
      _translatedText = '';
      _statusMsg = '';
    });
  }

  // ─────────────── VOICE TTS ───────────────

  Future<void> _speakSource() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    if (_isSpeakingSource) {
      await _voiceService.stop();
      setState(() => _isSpeakingSource = false);
      return;
    }
    setState(() {
      _isSpeakingSource = true;
      _isSpeakingTarget = false;
    });
    await _voiceService.speak(text, _sourceLang.code);
    if (mounted) setState(() => _isSpeakingSource = false);
  }

  Future<void> _speakTarget() async {
    if (_translatedText.isEmpty) return;
    if (_isSpeakingTarget) {
      await _voiceService.stop();
      setState(() => _isSpeakingTarget = false);
      return;
    }
    setState(() {
      _isSpeakingTarget = true;
      _isSpeakingSource = false;
    });
    await _voiceService.speak(_translatedText, _targetLang.code);
    if (mounted) setState(() => _isSpeakingTarget = false);
  }

  // ─────────────── VOICE STT ───────────────

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _voiceService.stopListening();
      setState(() => _isListening = false);
      if (_inputController.text.isNotEmpty) _translate();
      return;
    }

    final ok = await _voiceService.initStt();
    if (!ok) {
      _showSnack('Microphone not available on this device.');
      return;
    }

    setState(() => _isListening = true);
    await _voiceService.startListening(
      languageCode: _sourceLang.code,
      onResult: (text, isFinal) {
        setState(() => _inputController.text = text);
        _inputController.selection = TextSelection.fromPosition(
          TextPosition(offset: text.length),
        );
        if (isFinal) {
          setState(() => _isListening = false);
          _translate();
        }
      },
    );
  }

  // ─────────────── CLIPBOARD ───────────────

  void _copyTranslation() {
    if (_translatedText.isEmpty) return;
    Clipboard.setData(ClipboardData(text: _translatedText));
    _showSnack('Copied to clipboard');
  }

  // ─────────────── HISTORY ───────────────

  Future<void> _openHistory() async {
    final result = await Navigator.push<TranslationHistory>(
      context,
      MaterialPageRoute(builder: (_) => const HistoryScreen()),
    );
    if (result != null) {
      setState(() {
        _sourceLang = Language.fromCode(result.sourceLang);
        _targetLang = Language.fromCode(result.targetLang);
        _inputController.text = result.sourceText;
        _translatedText = result.translatedText;
      });
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mq = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(theme),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.fromLTRB(16, 0, 16, mq.viewInsets.bottom + 16),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    _buildLanguageBar(theme),
                    const SizedBox(height: 16),
                    _buildSourceCard(theme),
                    const SizedBox(height: 12),
                    _buildTargetCard(theme),
                    if (_statusMsg.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildStatusMsg(theme),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Lingua',
                style: GoogleFonts.sora(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.primary,
                  height: 1,
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2),
              Text(
                'Translate',
                style: GoogleFonts.sora(
                  fontSize: 13,
                  color: theme.colorScheme.onSurface.withOpacity(0.45),
                  letterSpacing: 2,
                ),
              ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: _openHistory,
            icon: const Icon(Icons.history_rounded),
            style: IconButton.styleFrom(
              backgroundColor:
                  theme.colorScheme.surfaceVariant.withOpacity(0.6),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(child: _langButton(_sourceLang, isSource: true, theme: theme)),
          AnimatedBuilder(
            animation: _swapAnim,
            builder: (_, child) => Transform.rotate(
              angle: _swapAnim.value * 3.14159,
              child: child,
            ),
            child: GestureDetector(
              onTap: _swapLanguages,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.swap_horiz_rounded,
                    color: Colors.white, size: 20),
              ),
            ),
          ),
          Expanded(child: _langButton(_targetLang, isSource: false, theme: theme)),
        ],
      ),
    );
  }

  Widget _langButton(Language lang,
      {required bool isSource, required ThemeData theme}) {
    return GestureDetector(
      onTap: () => LanguagePickerSheet.show(
        context,
        selected: lang,
        title: isSource ? 'Source Language' : 'Target Language',
        onSelect: (l) {
          setState(() {
            if (isSource) {
              _sourceLang = l;
            } else {
              _targetLang = l;
            }
          });
          if (_inputController.text.isNotEmpty) _translate();
        },
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(lang.flag, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                lang.name,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.sora(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.expand_more_rounded,
                size: 18,
                color: theme.colorScheme.onSurface.withOpacity(0.4)),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceCard(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                Text(
                  _sourceLang.flag,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 8),
                Text(
                  _sourceLang.name,
                  style: GoogleFonts.sora(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withOpacity(0.45),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                if (_inputController.text.isNotEmpty)
                  GestureDetector(
                    onTap: _clearInput,
                    child: Icon(Icons.close_rounded,
                        size: 18,
                        color: theme.colorScheme.onSurface.withOpacity(0.4)),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: _inputController,
              focusNode: _inputFocus,
              maxLines: 6,
              minLines: 3,
              onChanged: _onTextChanged,
              style: GoogleFonts.sora(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
                height: 1.4,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Type or speak…',
                hintStyle: GoogleFonts.sora(
                  fontSize: 22,
                  color: theme.colorScheme.onSurface.withOpacity(0.25),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              children: [
                // Mic button
                _MicButton(
                  isListening: _isListening,
                  onTap: _toggleListening,
                  theme: theme,
                ),
                const SizedBox(width: 8),
                VoiceButton(
                  isActive: _isSpeakingSource,
                  onTap: _speakSource,
                  icon: Icons.volume_up_rounded,
                  tooltip: 'Speak source',
                  color: theme.colorScheme.tertiary,
                ),
                const Spacer(),
                Text(
                  '${_inputController.text.length} chars',
                  style: GoogleFonts.sora(
                    fontSize: 11,
                    color: theme.colorScheme.onSurface.withOpacity(0.3),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 150.ms).slideY(begin: 0.05);
  }

  Widget _buildTargetCard(ThemeData theme) {
    final hasResult = _translatedText.isNotEmpty;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: hasResult
            ? theme.colorScheme.primary.withOpacity(0.07)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: hasResult
            ? Border.all(
                color: theme.colorScheme.primary.withOpacity(0.2), width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: hasResult
                ? theme.colorScheme.primary.withOpacity(0.08)
                : Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                Text(_targetLang.flag,
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(
                  _targetLang.name,
                  style: GoogleFonts.sora(
                    fontSize: 12,
                    color: theme.colorScheme.primary.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                if (_isTranslating)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.primary,
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: _isTranslating && _translatedText.isEmpty
                ? _buildSkeletonLines(theme)
                : hasResult
                    ? Text(
                        _translatedText,
                        style: GoogleFonts.sora(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                          height: 1.4,
                        ),
                      ).animate().fadeIn(duration: 300.ms)
                    : Text(
                        'Translation will appear here',
                        style: GoogleFonts.sora(
                          fontSize: 18,
                          color: theme.colorScheme.onSurface.withOpacity(0.2),
                        ),
                      ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Row(
              children: [
                VoiceButton(
                  isActive: _isSpeakingTarget,
                  onTap: _speakTarget,
                  icon: Icons.volume_up_rounded,
                  tooltip: 'Speak translation',
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                VoiceButton(
                  isActive: false,
                  onTap: _copyTranslation,
                  icon: Icons.copy_rounded,
                  tooltip: 'Copy translation',
                ),
                const Spacer(),
                if (hasResult)
                  GestureDetector(
                    onTap: () {
                      // Share
                      Clipboard.setData(ClipboardData(
                          text:
                              '${_inputController.text}\n→ $_translatedText'));
                      _showSnack('Copied both texts!');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.share_rounded,
                              size: 14, color: theme.colorScheme.primary),
                          const SizedBox(width: 4),
                          Text(
                            'Share',
                            style: GoogleFonts.sora(
                              fontSize: 12,
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 250.ms).slideY(begin: 0.05);
  }

  Widget _buildSkeletonLines(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _skeletonLine(theme, 0.8),
        const SizedBox(height: 8),
        _skeletonLine(theme, 0.6),
        const SizedBox(height: 8),
        _skeletonLine(theme, 0.4),
      ],
    );
  }

  Widget _skeletonLine(ThemeData theme, double widthFactor) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: Container(
        height: 22,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
      )
          .animate(onPlay: (c) => c.repeat())
          .shimmer(duration: 1200.ms, color: theme.colorScheme.primary.withOpacity(0.15)),
    );
  }

  Widget _buildStatusMsg(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.wifi_off_rounded,
              color: theme.colorScheme.onErrorContainer, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _statusMsg,
              style: GoogleFonts.sora(
                fontSize: 13,
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MicButton extends StatelessWidget {
  final bool isListening;
  final VoidCallback onTap;
  final ThemeData theme;

  const _MicButton(
      {required this.isListening, required this.onTap, required this.theme});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isListening
              ? theme.colorScheme.error
              : theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isListening
              ? [
                  BoxShadow(
                    color: theme.colorScheme.error.withOpacity(0.4),
                    blurRadius: 12,
                    spreadRadius: 2,
                  )
                ]
              : [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ],
        ),
        child: Icon(
          isListening ? Icons.stop_rounded : Icons.mic_rounded,
          color: Colors.white,
          size: 22,
        ),
      )
          .animate(target: isListening ? 1 : 0)
          .scale(
              end: const Offset(1.05, 1.05),
              duration: 600.ms,
              curve: Curves.easeInOut)
          .then()
          .scale(end: const Offset(1.0, 1.0), duration: 600.ms),
    );
  }
}
