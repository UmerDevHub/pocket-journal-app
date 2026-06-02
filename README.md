# 📓 Pocket Journal

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat-square&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=flat-square&logo=dart&logoColor=white)
![SQLite](https://img.shields.io/badge/SQLite-003B57?style=flat-square&logo=sqlite&logoColor=white)
![Material3](https://img.shields.io/badge/Material_3-757575?style=flat-square&logo=materialdesign&logoColor=white)
![Play Store](https://img.shields.io/badge/Google_Play-Published-3DDC84?style=flat-square&logo=google-play&logoColor=white)
![Downloads](https://img.shields.io/badge/Downloads-10%2B-blue?style=flat-square)
![Rating](https://img.shields.io/badge/Rated-3%2B-green?style=flat-square)

> A beautiful, offline-first personal journal app built with Flutter and SQLite. Your thoughts stay 100% private — no accounts, no cloud, no data collection.

[<img src="https://play.google.com/intl/en_us/badges/static/images/badges/en_badge_web_generic.png" width="200"/>](https://play.google.com/store/apps/details?id=com.umer.pocketjournal.app2026&hl=en)

---

## ✨ Features

- 📝 **Rich journal editor** — distraction-free writing with title, description, and color categories
- 😊 **Mood tracking** — log emotions daily and visualize patterns over time
- 🔥 **Streak counter** — build consistent journaling habits with daily tracking
- 📊 **Statistics dashboard** — writing patterns, entry frequency, and word count insights
- 💡 **Writing prompts** — never face a blank page again
- 📋 **Quick templates** — gratitude, daily reflection, and more
- 🌓 **Dark mode** — full Material 3 adaptive theming
- 🔒 **100% offline** — all data stored locally in SQLite, never leaves your device
- 📤 **Share entries** — export as text to any app
- 🚫 **No ads. No subscriptions.**

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter (Dart 3.x) |
| Architecture | Clean Architecture + MVVM |
| State Management | Provider |
| Local Database | SQLite via `sqflite` |
| Preferences | `shared_preferences` |
| Design System | Material 3 + Google Fonts (Outfit) |
| Utilities | `intl`, `uuid` |

---

## 📂 Architecture

```
lib/
├── models/
│   └── note.dart                   ← Note entity & DB mapping
├── providers/
│   ├── notes_provider.dart         ← State for note operations
│   └── theme_provider.dart         ← App brightness state
├── screens/
│   ├── splash_screen.dart          ← Launch animations
│   ├── notes_list_screen.dart      ← Journal grid listing
│   ├── note_editor_screen.dart     ← Add / edit entries
│   ├── stats_screen.dart           ← Writing habit statistics
│   ├── settings_screen.dart        ← Customizations & privacy
│   └── privacy_policy_screen.dart  ← Data policy view
├── services/
│   ├── database_service.dart       ← SQLite helper & queries
│   ├── stats_service.dart          ← Notes metrics logic
│   └── theme_service.dart          ← Theme persistence
└── widgets/                        ← Shared reusable UI components
```

---

## 🚀 Run Locally

**Prerequisites:** Flutter SDK (stable channel), Android Studio or VS Code, Android emulator or physical device.

```bash
# Clone the repo
git clone https://github.com/UmerDevHub/pocket-journal-app.git
cd pocket-journal-app

# Install dependencies
flutter pub get

# Run the app
flutter run
```

---

## 🔒 Privacy

Pocket Journal does not collect, share, or transmit any user data. All journal entries are stored exclusively in the app's local SQLite database on your device.

[Privacy Policy](https://privacy-policy-nine-omega.vercel.app/)

---

*Published on Google Play — DarkByte Technologies*
