# Pocket Journal 📓

<p align="center">
  <img src="web/favicon.png" alt="Pocket Journal Logo" width="100" height="100" style="border-radius: 20%;" />
</p>

<p align="center">
  <strong>Pocket Journal</strong> is a premium, offline-first personal diary application built with Flutter. It is designed to help you capture your thoughts, analyze your writing habits, and maintain 100% control of your personal data.
</p>

<p align="center">
  <a href="https://play.google.com/store/apps/details?id=com.umer.pocketjournal.app2026&hl=en">
    <img alt="Get it on Google Play" src="https://play.google.com/intl/en_us/badges/static/images/badges/en_badge_web_generic.png" width="220"/>
  </a>
</p>

---

## 📱 Screenshots & UI Showcase

| Splash Screen | Journal Dashboard | Stats & Analytics | Editor (Dark Mode) |
| --- | --- | --- | --- |
| <img src="https://raw.githubusercontent.com/UmerDevHub/pocket-journal-app/main/screenshots/splash.png" width="160" alt="Splash Screen" /> | <img src="https://raw.githubusercontent.com/UmerDevHub/pocket-journal-app/main/screenshots/dashboard.png" width="160" alt="Dashboard" /> | <img src="https://raw.githubusercontent.com/UmerDevHub/pocket-journal-app/main/screenshots/stats.png" width="160" alt="Stats" /> | <img src="https://raw.githubusercontent.com/UmerDevHub/pocket-journal-app/main/screenshots/editor_dark.png" width="160" alt="Editor Dark" /> |

*(Add your screenshots to a `screenshots/` directory in this repository to showcase the app's clean UI!)*

---

## ✨ Features

- 📝 **Rich Note & Journal Editor:** Capture thoughts seamlessly with title, description, and custom color categories.
- 📊 **Insightful Stats & Analytics:** Track your writing patterns, entry frequencies, word counts, and mood insights.
- 🌓 **Dynamic Adaptive Theme:** Full Material 3 support with dark and light modes that sync with system preferences.
- 🔒 **Privacy-First (100% Offline):** Uses a local SQLite database, meaning your journals never touch external cloud servers.
- 📤 **Quick Sharing:** Export and share your entries as text directly with messaging or social apps.
- 💡 **Writing Prompts:** Integrated prompts and motivational cards to spark daily reflection.

---

## 🛠️ Technology Stack & Libraries

- **Framework:** [Flutter](https://flutter.dev/) (Dart 3.x)
- **Architecture:** Clean Architecture with MVVM / Provider Pattern
- **State Management:** [`provider`](https://pub.dev/packages/provider)
- **Local Persistence:** [`sqflite`](https://pub.dev/packages/sqflite) (SQLite for mobile) & [`shared_preferences`](https://pub.dev/packages/shared_preferences) (User preferences)
- **Design System:** Material 3 with [`google_fonts`](https://pub.dev/packages/google_fonts) (Outfit typeface)
- **Formatting & Utilities:** [`intl`](https://pub.dev/packages/intl) & [`uuid`](https://pub.dev/packages/uuid)

---

## 📂 Codebase Architecture

The app is built following scalable clean architecture principles:
```text
lib/
├── models/
│   └── note.dart                 # Note entity & database mapping
├── providers/
│   ├── notes_provider.dart       # State provider for note operations
│   └── theme_provider.dart       # State provider for app brightness
├── screens/
│   ├── splash_screen.dart        # Launch animations
│   ├── notes_list_screen.dart    # Feed/Journal grid listing
│   ├── note_editor_screen.dart   # Editor sheet for adding/modifying logs
│   ├── stats_screen.dart         # Writing habit statistics
│   ├── settings_screen.dart      # Customizations & privacy links
│   └── privacy_policy_screen.dart # User data policy view
├── services/
│   ├── database_service.dart     # SQLite Database helper & queries
│   ├── stats_service.dart        # Logic helper for notes metrics
│   └── theme_service.dart        # Saved settings theme storage helper
└── widgets/                      # Shared reusable UI elements
```

---

## 🚀 Setting Up Locally

Follow these instructions to run the project in development mode:

### Prerequisites

* [Flutter SDK](https://docs.flutter.dev/get-started/install) installed on your system (stable channel).
* Android Studio, IntelliJ IDEA, or VS Code.
* A configured Android Emulator, iOS Simulator, or physical device.

### Setup Steps

1. **Clone the Repository:**
   ```bash
   git clone https://github.com/UmerDevHub/pocket-journal-app.git
   cd pocket-journal-app
   ```

2. **Fetch Dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the App:**
   ```bash
   flutter run
   ```

---

## 🛡️ License & Privacy

This application is dedicated to privacy. It does not collect, sell, or transmit any user data. All information stays safely stored in the app's local SQLite database files.

---

<p align="center">
  Made with ❤️ by <a href="https://github.com/UmerDevHub">UmerDevHub</a>
</p>
