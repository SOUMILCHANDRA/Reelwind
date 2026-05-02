# Reelwind 🎬✨

**The ultimate cinematic dashboard for Letterboxd power users.**

Reelwind is a high-fidelity desktop application built with Flutter that transforms your raw Letterboxd data into a stunning, interactive cinematic experience.

![Reelwind Hero](https://github.com/SOUMILCHANDRA/Reelwind/raw/main/assets/hero_preview.png) *(Preview coming soon)*

## 🚀 Key Features

- **Deep Letterboxd Integration**: Import and unify your `diary.csv`, `ratings.csv`, `watched.csv`, and `reviews.csv` into a single source of truth.
- **TMDB Enrichment**: Automatically fetches high-res posters, director bios, genres, and runtimes using the TMDB API.
- **Intelligent Drill-Downs**: Click any Genre or Director on your dashboard to instantly explore your library.
- **Privacy First**: Your data stays on your machine. Reelwind uses a local SQLite database for maximum speed and security.
- **Modern Aesthetics**: A premium, neon-noir inspired dark mode designed for movie lovers.

## 🛠️ Technology Stack

- **Framework**: [Flutter](https://flutter.dev) (Windows Desktop)
- **Database**: [SQLite (FFI)](https://pub.dev/packages/sqflite_common_ffi)
- **API**: [The Movie Database (TMDB)](https://www.themoviedb.org/documentation/api)
- **State Management**: Provider

## 🏁 Getting Started

### Prerequisites
- Flutter SDK installed and configured for Windows.
- A TMDB API Read Access Token (Bearer Token).

### Setup
1. **Clone the repository**:
   ```bash
   git clone https://github.com/SOUMILCHANDRA/Reelwind.git
   cd reelwind
   ```

2. **Configure Environment**:
   Create a `.env` file in the root directory:
   ```env
   TMDB_ACCESS_TOKEN=your_bearer_token_here
   ```

3. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

4. **Launch Reelwind**:
   ```bash
   flutter run -d windows
   ```

## 🤝 Contributing
Contributions are welcome! If you have ideas for new metrics, charts, or UI improvements, feel free to open a PR.

---
*Built with ❤️ for the cinematic community.
By Soumil Chandra*
