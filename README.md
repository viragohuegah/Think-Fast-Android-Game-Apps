# 🚀 Think Fast — Speed Math Reaction Game

A Flutter mobile game that challenges players to solve quick arithmetic problems (addition) and determine if the result is even or odd. Built for Android with a focus on responsive gameplay, haptic feedback, and audio immersion.

![Version](https://img.shields.io/badge/version-1.0.0-blue)
![Flutter](https://img.shields.io/badge/Flutter-3.3%2B-02569B?logo=flutter)
![Android](https://img.shields.io/badge/Android-API%2026%2B-3DDC84?logo=android)
![License](https://img.shields.io/badge/license-MIT-green)

---

# 🚀 Think Fast — Speed Math Reaction Game

## 🎥 Demo Video
[![Watch the demo](https://img.youtube.com/vi/VIDEO_ID/0.jpg)](https://www.youtube.com/shorts/LIyGIR7-r6s)

---

## 📋 Table of Contents

- [Features](#-features)
- [Tech Stack](#-tech-stack)
- [Architecture](#-architecture)
- [Project Structure](#-project-structure)
- [Game Mechanics](#-game-mechanics)
- [Prerequisites](#-prerequisites)
- [Installation & Setup](#-installation--setup)
- [Development](#-development)
- [Building for Production](#-building-for-production)
- [Configuration](#-configuration)
- [Contributing](#-contributing)
- [License](#-license)

---

## ✨ Features

- **Fast-Paced Gameplay**: Answer as many math questions as possible in 60 seconds per round
- **Customizable Rounds**: Players can choose number of rounds (adjustable difficulty)
- **React & Respond**: Quick arithmetic (addition) + parity check (even/odd)
- **Haptic Feedback**: Tactile responses on correct/incorrect answers
- **Audio Cues**: Immersive sound effects for:
  - Correct answers
  - Wrong answers
  - Countdown ticks
  - Round start/end signals
- **Performance Tracking**: Detailed statistics including:
  - Accuracy per round
  - Response times
  - Correct/incorrect answer counts
- **Android Optimized**: Built specifically for Android (API 26+) with native performance
- **Portrait-Locked UI**: Optimized fullscreen experience
- **Material Design**: Clean, modern UI with custom theming
- **Statistics Visualization**: Charts displaying round-by-round performance

---

## 🛠️ Tech Stack

### Core Framework
- **Flutter** (≥3.3.0, <4.0.0) — Cross-platform mobile development
- **Dart** — Primary language

### Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `fl_chart` | ^0.68.0 | Performance data visualization (charts) |
| `audioplayers` | ^6.0.0 | Audio playback (SFX, countdown sounds) |
| `flutter_lints` | ^4.0.0 | Code quality & style linting |

### Dev Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_launcher_icons` | ^0.14.1 | App icon generation |
| `flutter_native_splash` | ^2.4.1 | Native splash screen |
| `flutter_test` | SDK | Widget and unit testing |

### Native Features
- **Haptic Engine**: Flutter Services (built-in, no external dependency)
- **Status Bar Control**: Fullscreen orientation management

---

## 🏗️ Architecture

Think Fast follows a **layered architecture** with clear separation of concerns:

```
lib/
├── main.dart                    # App entry point
├── core/                        # Core services & utilities
│   ├── audio/                   # Audio playback service
│   ├── haptic/                  # Haptic feedback service
│   ├── localization/            # i18n & multi-language support
│   └── theme/                   # Material theme configuration
├── models/                      # Data models
│   ├── question_result.dart     # Single question result
│   └── round_result.dart        # Complete round results
├── services/                    # Business logic
│   └── game_engine.dart         # Pure-Dart game state & logic
├── screens/                     # UI pages
│   ├── home_screen.dart         # Game setup & menu
│   ├── game_screen.dart         # Active gameplay
│   └── result_screen.dart       # Post-round statistics
└── widgets/                     # Reusable UI components
    ├── answer_button.dart       # Answer selection buttons
    ├── countdown_widget.dart    # Countdown timer display
    ├── question_card.dart       # Question display component
    └── ...
```

### Design Principles

1. **Pure Dart Game Engine**
   - `GameEngine` class contains all game logic with **zero Flutter dependencies**
   - Easier to test, reuse, and maintain
   - UI layer observes engine state via callbacks

2. **Service Layer**
   - `AudioService` — Centralized audio playback management
   - `HapticService` — Unified haptic feedback API
   - Single instance pattern for singleton services

3. **Immutable Models**
   - `Question`, `QuestionResult`, `RoundResult` use final fields
   - Predictable state management

4. **UI Composition**
   - Reusable widgets (`AnswerButton`, `CountdownWidget`, etc.)
   - Stateful screens for local state management
   - Clear separation between presentation and logic

---

## 📁 Project Structure

```
think_fast/
├── .gitignore                   # Git ignore rules (Android-focused)
├── analysis_options.yaml        # Dart analysis config
├── pubspec.yaml                 # Project dependencies & config
├── pubspec.lock                 # Lock file (dependency versions)
├── README.md                    # Project documentation
├── WINDOWS_SETUP.md             # Windows development setup guide
├── PLAYSTORE_GUIDE.md           # Google Play Store deployment
│
├── lib/                         # Dart source code
│   ├── main.dart
│   ├── core/
│   ├── models/
│   ├── services/
│   ├── screens/
│   └── widgets/
│
├── assets/                      # Game assets
│   ├── audio/                   # Sound effects (MP3, AIFF)
│   └── images/                  # Icons, splash, tutorial images
│
├── test/                        # Unit & widget tests
│   └── widget_test.dart
│
├── android/                     # Android native code
│   ├── app/
│   ├── gradle/
│   ├── key.properties           # SIGN KEY CONFIG (gitignored)
│   └── local.properties         # LOCAL CONFIG (gitignored)
│
└── build/                       # Flutter build outputs (gitignored)
```

---

## 🎮 Game Mechanics

### Round Flow

1. **Setup Phase**: Player selects number of rounds (default: 5)
2. **Round Start**: 60-second timer begins
3. **Question Loop** (repeats until timer expires):
   - Display random addition: `a + b` (0–9 + 0–9)
   - Player taps "Even" or "Odd"
   - Game records: response time + correctness
   - Next question appears immediately
4. **Round End**: Display round statistics
5. **Game Over**: Show cumulative stats across all rounds

### Question Model

```dart
// Example: 7 + 5 = 12 (even)
Question(a: 7, b: 5)
  .result         // 12
  .isEven         // true
  .correctAnswer  // 0 (0 = Even)
```

### Scoring & Statistics

For each question, the game tracks:
- ✅/❌ Correctness
- ⏱️ Response time (accurate to 0.01s)
- 📊 Accuracy percentage per round
- 🎯 Total questions answered

---

## 📦 Prerequisites

### System Requirements

- **Windows / macOS / Linux** (development machine)
- **Android Studio / SDK** (Android API 26+ for production)
- **Java Development Kit (JDK 11+)**

### Required Tools

```bash
# Install Flutter
# https://flutter.dev/docs/get-started/install

flutter --version  # Verify installation (should be ≥3.3.0)
dart --version     # Verify Dart (should be ≥3.3.0)
```

### Environment Setup

```bash
# Get pub packages
flutter pub get

# Verify Android setup
flutter doctor    # Check for any setup issues
```

---

## 💻 Installation & Setup

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/think_fast.git
cd think_fast
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Generate Assets (Icons & Splash)

```bash
# Generate app launcher icons
flutter pub run flutter_launcher_icons:main

# Generate native splash screens
flutter pub run flutter_native_splash:create
```

### 4. Fix Code (Optional)

```bash
# Apply automatic code fixes
dart fix --apply
```

### 5. Run on Android Device/Emulator

```bash
# List available Android devices
flutter devices

# Run on default Android device
flutter run

# Run on specific Android device
flutter run -d <device_id>

# Run with release optimizations
flutter run --release
```

---

## 🔧 Development

### Running Tests

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/widget_test.dart
```

### Code Analysis

```bash
# Check for linting issues
flutter analyze

# Fix auto-fixable issues
dart fix --apply

# Format code
dart format lib/
```

### Hot Reload / Hot Restart

During development:
- Press **`r`** to hot reload (applies code changes, preserves app state)
- Press **`R`** to hot restart (full restart, clears app state)
- Press **`q`** to quit

### Debugging

```bash
# Run with debug prints
flutter run

# View logs
flutter logs

# Verbose logging
flutter run -v
```

---

## 📱 Building for Production

### Android Build

#### Prerequisites
- Android SDK (API 26+)
- Java Development Kit (JDK 11+)
- Signing key (`.jks` keystore)

#### Generate Release APK

```bash
# Clean previous builds
flutter clean

# Build APK for distribution
flutter build apk --release

# Output: build/app/outputs/apk/release/app-release.apk
```

#### Generate App Bundle (Google Play)

```bash
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab
```

#### Sign APK Manually (if needed)

```bash
# Generate keystore (do this once, keep it safe!)
keytool -genkey -v -keystore ~/key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias android_key -storepass password -keypass password

# Sign APK
jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 \
  -keystore ~/key.jks \
  build/app/outputs/apk/release/app-release.apk android_key
```

### Code Style

- Follow [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Use `dart format` to auto-format
- Run `flutter analyze` before committing


## 📄 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

## 🆘 Support & Troubleshooting

### Common Issues

#### "flutter: command not found"
```bash
# Add Flutter to PATH
export PATH="$PATH:`pwd`/flutter/bin"
```

#### "No devices found"
```bash
# List Android devices
flutter devices

# Start Android emulator
# Open Android Studio → Device Manager → Create Virtual Device
```

#### "Android build fails"
```bash
# Clean and rebuild
flutter clean
flutter pub get

# Check Android setup
flutter doctor --android-licenses

# Accept Android licenses
flutter doctor --android-licenses
```

#### "Audio not playing"
- Verify audio files are in [assets/audio/](assets/audio/)
- Check [pubspec.yaml](pubspec.yaml) asset declarations
- Rebuild with `flutter clean && flutter pub get`

- Flutter team for the amazing framework
- Audio assets from [Freesound.org](https://freesound.org)

---

**Happy coding! 🚀**

Made with ❤️ using Flutter
