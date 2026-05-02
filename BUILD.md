# Building Reelwind

Since Reelwind is a Flutter application, you will need the Flutter SDK installed on your machine to build and run it.

## Prerequisites

1.  **Install Flutter**: Follow the [Official Flutter Installation Guide](https://docs.flutter.dev/get-started/install) for your OS (Windows/macOS/Linux).
2.  **TMDB API Key**:
    *   Go to [The Movie Database (TMDB)](https://www.themoviedb.org/settings/api) and create an API key.
    *   Open the `.env` file in the project root and replace `your_key_here` with your actual key.

## Setup Instructions

Once Flutter is installed, follow these steps in your terminal inside the project directory (`e:\reelwind`):

1.  **Initialize Platform Folders**:
    The repository contains the core logic (`lib/`) but does not include the large platform-specific folders (`android/`, `ios/`). Generate them by running:
    ```powershell
    flutter create .
    ```

2.  **Install Dependencies**:
    Fetch the required packages defined in `pubspec.yaml`:
    ```powershell
    flutter pub get
    ```

3.  **Run the App**:
    Connect a physical device or start an emulator, then run:
    ```powershell
    flutter run
    ```

## Building for Production

### Android (APK)
```powershell
flutter build apk --release
```

### iOS
*Requires a Mac with Xcode installed.*
```powershell
flutter build ios --release
```

---

### Troubleshooting

*   **Flutter command not found**: Ensure the Flutter `bin` folder is added to your system's PATH environment variable.
*   **Missing .env**: Ensure you have a `.env` file at the root containing:
    `TMDB_API_KEY=your_actual_key`
