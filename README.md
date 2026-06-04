<div align="center">

# PinPoint

**Multiplayer geography party game: see a landmark, drop a pin, score points based on accuracy.**

<br/>

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![BLoC](https://img.shields.io/badge/State-BLoC-blueviolet)](https://bloclibrary.dev)
[![CI](https://github.com/mohamedelesawy19/pin_point/actions/workflows/ci.yml/badge.svg)](https://github.com/mohamedelesawy19/pin_point/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

<br/>

[Features](#-features) · [Getting Started](#-getting-started) · [Architecture](#-architecture) · [Contributing](#-contributing) · [License](#-license)

</div>

---

## 📖 Overview

```
PinPoint is a real-time multiplayer party game where players compete to identify famous landmarks around the world. A landmark image is shown, and each player places a pin on a world map to guess its location.

The closer the guess is to the actual location, the more points the player earns.

Built with Flutter and Firebase, the game supports real-time multiplayer rooms, synchronized gameplay, and scalable backend logic using cloud functions.
```

---

## ✨ Features

| Feature | Description |
|---|---|
| 🎮 **Multiplayer Party Mode** | Create or join rooms using a 6-digit party code |
| 🌍 **Geography Guessing Gameplay** | Identify global landmarks from images |
| 📍 **Map-Based Interaction** | Place pins on an interactive world map |
| ⏱️ **Timed Rounds** | Each round has a configurable countdown (30s / 45s / 60s) |
| 🏆 **Score System** | Points based on distance from correct location |
| ⚡ **Real-Time Sync** | Live updates using Firebase Realtime Database |
| 🔒 **Fair Gameplay** | Server-side logic prevents cheating |

---

## 🎮 Gameplay

### Host Flow

1. Create a new party room
2. Configure game settings (round time, number of rounds)
3. Share the 6-digit room code
4. Wait for players to join
5. Start the game

### Player Flow

1. Join a party using code
2. View landmark image each round
3. Open map and place a pin
4. Submit guess before timer ends
5. View results and leaderboard

---

## 🚀 Getting Started

### Prerequisites

| Tool | Version | Notes |
|---|---|---|
| [Flutter SDK](https://docs.flutter.dev/get-started/install) | `≥ 3.x` | Stable channel |
| [Dart SDK](https://dart.dev/get-dart) | `≥ 3.x` | Bundled with Flutter |
| [Firebase CLI](https://firebase.google.com/docs/cli) | Latest | |

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/mohamedelesawy19/pin_point.git
cd pin_point

# 2. Install dependencies
flutter pub get

# 3. Run the app
flutter run
```

### Running on Specific Platforms

```bash
flutter run -d ios          # iOS Simulator
flutter run -d android      # Android Emulator
flutter run -d chrome       # Web (Chrome)
flutter run -d macos        # macOS Desktop
flutter run -d windows      # Windows Desktop
flutter run -d linux        # Linux Desktop
```

---

## 🏗 Architecture

This project follows **Clean Architecture** with a **feature-first** folder structure,
using [flutter_bloc](https://bloclibrary.dev/) for state management.

```
lib/
├── core/                   # App-wide utilities & shared code
│   ├── constants/          # Colors, text styles, dimensions
│   ├── errors/             # Failure types & error handling
│   ├── extensions/         # Dart extension methods
│   ├── network/            # Dio client, interceptors
│   ├── router/             # GoRouter configuration
│   └── theme/              # Light & dark ThemeData
│
├── features/               # One folder per feature
│   └── feature_name/
│       ├── data/           # Remote & local data sources, models
│       ├── domain/         # Entities, repository interfaces, use cases
│       └── presentation/
│           ├── screens/
│           ├── widgets/
│           └── bloc/      # Blocs + States + Events
│
└── main.dart
```

---

## 🧪 Testing

```bash
# Unit & widget tests
flutter test

# Integration tests
flutter test integration_test/

# Test coverage report
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
# Open report
coverage/html/index.html
```

The project targets **≥ 80% code coverage** on domain and data layers.

---

## ⚙️ Continuous Integration

GitHub Actions automatically validates every push and pull request.

### Quality Gates

- ✅ Code formatting (`dart format`)
- ✅ Static analysis (`flutter analyze --fatal-infos`)
- ✅ Unit & widget tests
- ✅ Minimum code coverage of **80%**
- ✅ Semantic Pull Request title validation

### Workflow

```text
Push / Pull Request
        │
        ▼
   Format Check
        │
        ▼
 Static Analysis
        │
        ▼
      Tests
        │
        ▼
  Coverage ≥ 80%
        │
        ▼
    CI Pass ✅
```

All checks must pass before changes can be merged into protected branches.

---

## 🤝 Contributing

Contributions are welcome! Please read the guidelines before submitting a PR.

1. **Fork** the repository and create your branch from `develop`.
2. **Follow** the existing code style (`dart format` + `flutter analyze` must pass).
3. **Write tests** for any new functionality.
4. **Open a Pull Request** against `develop` with a clear description.

---

## 🔒 Security

If you discover a security vulnerability, please **do not** open a public issue.
Email us at **moelesawy19@gmail.com** and we will respond within 48 hours.

---

## 📄 License

```
MIT License — Copyright (c) 2026 Mohamed Elesawy
```

See the full [`LICENSE`](LICENSE) file for details.

---

## 🙏 Acknowledgements

- [Flutter](https://flutter.dev) — the framework that makes this possible.
- [flutter_bloc](https://bloclibrary.dev) — by [Felix Angelov](https://github.com/felangel).
- All open-source packages listed in [`pubspec.yaml`](pubspec.yaml).

---

<div align="center">

Made with ❤️ and [Flutter](https://flutter.dev)

<br/>

[![Email](https://img.shields.io/badge/Gmail-moelesawy19%40gmail.com-EA4335?style=flat&logo=gmail&logoColor=white)](mailto:moelesawy19@gmail.com)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-0A66C2?style=flat&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/mohamed-elesawy-070522257/)

</div>
