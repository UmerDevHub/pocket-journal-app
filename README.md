# Pocket Journal 📓

A beautiful, offline-first personal journal application built using Flutter. Pocket Journal allows you to capture your daily thoughts, track writing statistics, and maintain your privacy with complete local database storage.

---

## ✨ Features

- 📝 **Rich Journal Editor:** Easily create, view, and edit your journal entries.
- 📊 **Writing Analytics (Stats):** Track your writing progress, entry frequency, and journaling habits.
- 🌓 **Dynamic Theme System:** Seamlessly switch between beautiful Light and Dark modes.
- 🔒 **Privacy First:** All data is stored locally on your device via SQLite. No cloud syncing or tracking.
- 📤 **Easy Sharing:** Share your favorite thoughts or entries with friends or other apps.
- 📄 **Privacy Policy:** Clear built-in privacy policy compliance.

---

## 🛠️ Technology Stack

- **Framework:** [Flutter](https://flutter.dev/) (Dart)
- **State Management:** [Provider](https://pub.dev/packages/provider)
- **Local Database:** [sqflite](https://pub.dev/packages/sqflite) (SQLite)
- **Typography:** [Google Fonts (Outfit)](https://pub.dev/packages/google_fonts)
- **Preferences Storage:** [shared_preferences](https://pub.dev/packages/shared_preferences)
- **Date Formatting:** [intl](https://pub.dev/packages/intl)

---

## 📂 Project Structure

```text
lib/
├── models/
│   └── note.dart                 # Journal entry data model
├── providers/
│   ├── notes_provider.dart       # State management for journal entries
│   └── theme_provider.dart       # State management for light/dark theme
├── screens/
│   ├── splash_screen.dart        # Animated splash entry
│   ├── notes_list_screen.dart    # Dashboard with all journal entries
│   ├── note_editor_screen.dart   # Editor to create & edit entries
│   ├── stats_screen.dart         # Writing habits and analytics screen
│   ├── settings_screen.dart      # Application preferences and settings
│   └── privacy_policy_screen.dart # Data privacy information
├── services/
│   ├── database_service.dart     # SQLite helper methods
│   ├── stats_service.dart        # Logic for parsing journal analytics
│   └── theme_service.dart        # Saved theme persistence helper
└── widgets/                      # Reusable UI components
```

---

## 🚀 Getting Started

Follow these steps to run the application locally:

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed (Dart 3.x+)
- Android Studio, VS Code, or Xcode (for iOS) configured

### Run Locally

1. **Clone the repository:**
   ```bash
   git clone https://github.com/UmerDevHub/pocket-journal-app.git
   cd pocket-journal-app
   ```

2. **Get packages:**
   ```bash
   flutter pub get
   ```

3. **Run the application:**
   ```bash
   flutter run
   ```
