# 🌍 Lingua Translate — Flutter App

A beautiful, fully-featured mobile translation app with voice input/output built in Flutter.

---

## ✨ Features

| Feature | Description |
|---|---|
| 🔤 **Text Translation** | Translate between 30+ languages with auto-debounce (translates as you type) |
| 🎙️ **Voice Input (STT)** | Tap the mic and speak — your words are transcribed and translated automatically |
| 🔊 **Text-to-Speech** | Listen to the source text or translated result spoken aloud |
| 🔄 **Swap Languages** | One tap to swap source ↔ target and reverse the translation |
| 📋 **Copy & Share** | Copy the translation or both texts to clipboard |
| 🕓 **History** | Last 100 translations saved locally, with timestamps |
| ⭐ **Favorites** | Star any history item to save it to your Favorites tab |
| 🌙 **Dark Mode** | Full dark theme support (follows system or can be toggled) |
| 🇵🇰 **Urdu Support** | Includes Urdu with proper TTS/STT locale mapping |

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK ≥ 3.10.0
- Dart SDK ≥ 3.0.0
- Android Studio / Xcode for device testing
- A physical device or emulator with internet access

### Installation

```bash
# Clone or copy the project folder
cd translator_app

# Install dependencies
flutter pub get

# Run on Android
flutter run

# Run on iOS
flutter run
```

---

## 📁 Project Structure

```
lib/
├── main.dart                        # App entry point + theme
├── models/
│   ├── language.dart                # Language list (30 languages)
│   └── translation_history.dart     # History model
├── services/
│   ├── translation_service.dart     # Google Translate via `translator` package
│   ├── voice_service.dart           # TTS (flutter_tts) + STT (speech_to_text)
│   └── history_service.dart         # SharedPreferences persistence
├── screens/
│   ├── translator_screen.dart       # Main translation UI
│   └── history_screen.dart          # History + Favorites tabs
└── widgets/
    ├── language_picker_sheet.dart   # Bottom sheet language picker
    └── voice_button.dart            # Animated voice icon button
```

---

## 🔧 Dependencies

```yaml
translator: ^1.0.0          # Google Translate (free, no API key)
flutter_tts: ^3.8.5         # Text-to-Speech
speech_to_text: ^6.6.0      # Speech-to-Text
flutter_animate: ^4.3.0     # Smooth animations
google_fonts: ^6.1.0        # Sora typeface
shared_preferences: ^2.2.2  # Local history storage
connectivity_plus: ^5.0.2   # Network checks
```

---

## 📱 Permissions

### Android (`AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
```

### iOS (`Info.plist`)
```xml
<key>NSMicrophoneUsageDescription</key>
<string>Needed for voice input</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>Needed to transcribe speech</string>
```

---

## 🌐 Supported Languages (30)

English · Spanish · French · German · Italian · Portuguese · Russian · Japanese · Korean · Chinese (Simplified) · Arabic · Hindi · Urdu · Turkish · Dutch · Polish · Swedish · Norwegian · Danish · Finnish · Greek · Hebrew · Thai · Vietnamese · Indonesian · Malay · Ukrainian · Czech · Romanian · Hungarian

---

## 🎨 Design

- **Font**: Sora (Google Fonts)
- **Palette**: Indigo primary (`#5B6CF6`), Cyan secondary, Emerald tertiary
- **Style**: Soft card-based layout, rounded 20px corners, subtle shadows
- **Animations**: flutter_animate for fade/slide transitions, shimmer skeleton loaders, pulsing mic button

---

## 📝 Notes

- Translation uses the free `translator` package which proxies Google Translate — **no API key needed**.
- For production use, consider the official [Google Cloud Translation API](https://cloud.google.com/translate) for higher rate limits.
- STT requires a real device (not available in some emulators).
- TTS availability depends on installed voice packs on the device.
