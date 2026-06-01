class Language {
  final String name;
  final String code;
  final String flag;

  const Language({
    required this.name,
    required this.code,
    required this.flag,
  });

  static const List<Language> languages = [
    Language(name: 'English', code: 'en', flag: '🇺🇸'),
    Language(name: 'Spanish', code: 'es', flag: '🇪🇸'),
    Language(name: 'French', code: 'fr', flag: '🇫🇷'),
    Language(name: 'German', code: 'de', flag: '🇩🇪'),
    Language(name: 'Italian', code: 'it', flag: '🇮🇹'),
    Language(name: 'Portuguese', code: 'pt', flag: '🇧🇷'),
    Language(name: 'Russian', code: 'ru', flag: '🇷🇺'),
    Language(name: 'Japanese', code: 'ja', flag: '🇯🇵'),
    Language(name: 'Korean', code: 'ko', flag: '🇰🇷'),
    Language(name: 'Chinese', code: 'zh-cn', flag: '🇨🇳'),
    Language(name: 'Arabic', code: 'ar', flag: '🇸🇦'),
    Language(name: 'Hindi', code: 'hi', flag: '🇮🇳'),
    Language(name: 'Turkish', code: 'tr', flag: '🇹🇷'),
    Language(name: 'Dutch', code: 'nl', flag: '🇳🇱'),
    Language(name: 'Polish', code: 'pl', flag: '🇵🇱'),
    Language(name: 'Swedish', code: 'sv', flag: '🇸🇪'),
    Language(name: 'Norwegian', code: 'no', flag: '🇳🇴'),
    Language(name: 'Danish', code: 'da', flag: '🇩🇰'),
    Language(name: 'Finnish', code: 'fi', flag: '🇫🇮'),
    Language(name: 'Greek', code: 'el', flag: '🇬🇷'),
    Language(name: 'Hebrew', code: 'he', flag: '🇮🇱'),
    Language(name: 'Thai', code: 'th', flag: '🇹🇭'),
    Language(name: 'Vietnamese', code: 'vi', flag: '🇻🇳'),
    Language(name: 'Indonesian', code: 'id', flag: '🇮🇩'),
    Language(name: 'Malay', code: 'ms', flag: '🇲🇾'),
    Language(name: 'Ukrainian', code: 'uk', flag: '🇺🇦'),
    Language(name: 'Czech', code: 'cs', flag: '🇨🇿'),
    Language(name: 'Romanian', code: 'ro', flag: '🇷🇴'),
    Language(name: 'Hungarian', code: 'hu', flag: '🇭🇺'),
    Language(name: 'Urdu', code: 'ur', flag: '🇵🇰'),
  ];

  static Language fromCode(String code) {
    return languages.firstWhere(
      (l) => l.code == code,
      orElse: () => languages[0],
    );
  }
}
