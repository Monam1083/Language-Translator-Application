<div align="center">

<br/>


### 🌍 Translate. Listen. Speak. Understand.

**A beautiful Flutter translation app with real-time voice input, text-to-speech, and offline history — supporting 30+ languages.**

<br/>

[![Flutter](https://img.shields.io/badge/Flutter-3.10%2B-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0%2B-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-5B6CF6?style=for-the-badge)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-success?style=for-the-badge&logo=android&logoColor=white)](https://flutter.dev)
[![PRs Welcome](https://img.shields.io/badge/PRs-Welcome-10B981?style=for-the-badge)](CONTRIBUTING.md)

<br/>

</div>

---

## ✨ Features

<table>
<tr>
<td width="50%">

### 🔤 Smart Translation
- Translate between **30+ languages** instantly
- Auto-translates as you type *(700ms debounce)*
- Powered by Google Translate — **no API key needed**
- Swap source ↔ target with a single tap

</td>
<td width="50%">

### 🎙️ Voice Input (STT)
- Tap the mic and **speak naturally**
- Real-time partial results while listening
- Auto-triggers translation on speech end
- Works in the **source language** of your choice

</td>
</tr>
<tr>
<td width="50%">

### 🔊 Text-to-Speech (TTS)
- Listen to **both** source and translated text
- Native pronunciation per language
- Toggle on/off mid-playback
- Supports 20+ language voice packs

</td>
<td width="50%">

### 🕓 History & Favorites
- Last **100 translations** saved locally
- Star ⭐ important translations to Favorites tab
- Tap any history item to reload it instantly
- Clear all or delete individually

</td>
</tr>
</table>

**Plus:** 📋 Copy to clipboard · 🔗 Share translations · 🌙 Full dark mode · 🎨 Material 3 design · 🇵🇰 Urdu support

---

## 📱 Screenshots

> *Screenshots coming soon — run the app locally to see it in action!*

| Main Screen | Language Picker | History | Dark Mode |
|:-----------:|:---------------:|:-------:|:---------:|
| *(soon)* | *(soon)* | *(soon)* | *(soon)* |

---

## 🚀 Getting Started

### Prerequisites

| Tool | Version |
|------|---------|
| Flutter SDK | ≥ 3.10.0 |
| Dart SDK | ≥ 3.0.0 |
| Android SDK | API 21+ |
| Xcode *(iOS)* | 14+ |

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/YOUR_USERNAME/lingua-translate.git
cd lingua-translate/translator_app

# 2. Create the assets folder (required)
mkdir assets

# 3. Install dependencies
flutter pub get

# 4. Run the app
flutter run
```

> **Note:** Voice input (STT) requires a **real physical device**. It may not work on emulators.

---

## 🌐 Supported Languages

<details>
<summary>Click to expand — 30 languages</summary>

<br/>

| Flag | Language | Code | Flag | Language | Code |
|------|----------|------|------|----------|------|
| 🇺🇸 | English | `en` | 🇸🇦 | Arabic | `ar` |
| 🇪🇸 | Spanish | `es` | 🇮🇳 | Hindi | `hi` |
| 🇫🇷 | French | `fr` | 🇵🇰 | Urdu | `ur` |
| 🇩🇪 | German | `de` | 🇹🇷 | Turkish | `tr` |
| 🇮🇹 | Italian | `it` | 🇳🇱 | Dutch | `nl` |
| 🇧🇷 | Portuguese | `pt` | 🇵🇱 | Polish | `pl` |
| 🇷🇺 | Russian | `ru` | 🇸🇪 | Swedish | `sv` |
| 🇯🇵 | Japanese | `ja` | 🇳🇴 | Norwegian | `no` |
| 🇰🇷 | Korean | `ko` | 🇩🇰 | Danish | `da` |
| 🇨🇳 | Chinese (Simplified) | `zh-cn` | 🇫🇮 | Finnish | `fi` |
| 🇬🇷 | Greek | `el` | 🇹🇭 | Thai | `th` |
| 🇮🇱 | Hebrew | `he` | 🇻🇳 | Vietnamese | `vi` |
| 🇮🇩 | Indonesian | `id` | 🇲🇾 | Malay | `ms` |
| 🇺🇦 | Ukrainian | `uk` | 🇨🇿 | Czech | `cs` |
| 🇷🇴 | Romanian | `ro` | 🇭🇺 | Hungarian | `hu` |

</details>

---

## 🏗️ Project Structure

```
translator_app/
├── lib/
│   ├── main.dart                        # App entry + Material 3 theme
│   ├── models/
│   │   ├── language.dart                # 30 languages with flags & locale codes
│   │   └── translation_history.dart     # History data model + JSON serialization
│   ├── services/
│   │   ├── translation_service.dart     # Google Translate wrapper (singleton)
│   │   ├── voice_service.dart           # TTS (flutter_tts) + STT (speech_to_text)
│   │   └── history_service.dart         # SharedPreferences persistence layer
│   ├── screens/
│   │   ├── translator_screen.dart       # Main UI — input, output, controls
│   │   └── history_screen.dart          # History + Favorites tabs
│   └── widgets/
│       ├── language_picker_sheet.dart   # Searchable bottom sheet
│       └── voice_button.dart            # Animated voice icon button
├── android/
│   └── app/src/main/AndroidManifest.xml # INTERNET + RECORD_AUDIO permissions
├── ios/
│   └── Runner/Info.plist                # Microphone + Speech recognition permissions
├── assets/                              # Static assets folder (required)
└── pubspec.yaml
```

---

## 📦 Dependencies

```yaml
translator: ^1.0.0          # Google Translate — free, no API key
flutter_tts: ^3.8.5         # Text-to-Speech engine
speech_to_text: ^6.6.0      # Speech recognition
flutter_animate: ^4.3.0     # Smooth, chainable animations
google_fonts: ^6.1.0        # Sora typeface
shared_preferences: ^2.2.2  # Local history persistence
connectivity_plus: ^5.0.2   # Network state monitoring
cupertino_icons: ^1.0.6     # iOS-style icons
```

---

## 🔒 Permissions

### Android
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
```

### iOS
```xml
<key>NSMicrophoneUsageDescription</key>
<string>Used for voice input translation</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>Used to transcribe spoken words for translation</string>
```

---

## 🎨 Design System

| Token | Value |
|-------|-------|
| **Font** | Sora (Google Fonts) |
| **Primary** | `#5B6CF6` Indigo |
| **Secondary** | `#06B6D4` Cyan |
| **Tertiary** | `#10B981` Emerald |
| **Border Radius** | 20px cards, 14px inputs, 12px buttons |
| **Theme** | Material 3 · Light + Dark |

---

## 🛣️ Roadmap

- [ ] Offline translation support
- [ ] Camera / image translation (OCR)
- [ ] Widget for quick translations
- [ ] Multiple TTS voice options
- [ ] Export history as CSV
- [ ] Conversation mode (two-way live translation)
- [ ] Custom phrasebook

---

## 🤝 Contributing

Contributions are welcome! Please feel free to open an issue or submit a pull request.

```bash
# Fork the repo, then:
git checkout -b feature/your-feature-name
git commit -m "feat: add your feature"
git push origin feature/your-feature-name
# Open a Pull Request
```

---

## 📄 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

<div align="center">

Made with ❤️ using Flutter

⭐ **Star this repo** if you found it useful!

</div>
