# Wallhaven Flutter

A cross-platform Wallhaven client built with Flutter, supporting Android, iOS, Windows, Linux, and Web.

Based on the [Wallhaven API](https://wallhaven.cc/help/api) and inspired by [leoFitz1024/wallhaven](https://github.com/leoFitz1024/wallhaven).

## Features

-   **Browse Wallpapers**: View latest, hot, and top-rated wallpapers in a masonry grid layout.
-   **Search & Filter**:
    -   Search by keywords.
    -   Filter by Categories (General, Anime, People).
    -   Filter by Purity (SFW, Sketchy, NSFW).
    -   Sort by Date, Relevance, Views, Favorites, Toplist, etc.
-   **Wallpaper Details**: View high-resolution images and metadata (resolution, size, tags).
-   **Download**: Save wallpapers to your device (Gallery on Mobile, Downloads folder on Desktop).
-   **Settings**:
    -   **API Key Support**: Login with your Wallhaven API Key to access NSFW content and user settings.
    -   **Theme**: Switch between Light, Dark, and System themes.
    -   **Language**: Support for English and Chinese (中文).

## Screenshots

*(Add screenshots here)*

## Getting Started

### Prerequisites

-   [Flutter SDK](https://flutter.dev/docs/get-started/install)
-   [Dart SDK](https://dart.dev/get-dart)

### Installation

1.  **Clone the repository**

    ```bash
    git clone https://github.com/YOUR_USERNAME/wallhaven_flutter.git
    cd wallhaven_flutter
    ```

2.  **Install dependencies**

    ```bash
    flutter pub get
    ```

3.  **Generate localization files**

    ```bash
    flutter gen-l10n
    ```

4.  **Run the app**

    ```bash
    # Run on Windows
    flutter run -d windows

    # Run on Android
    flutter run -d android
    ```

## Project Structure

```
lib/
├── api/            # API client (Dio)
├── l10n/           # Localization files (.arb)
├── models/         # Data models
├── providers/      # State management (Provider)
├── screens/        # UI Screens (Home, Detail, Settings)
├── widgets/        # Reusable widgets
└── main.dart       # Entry point
```

## Dependencies

-   `dio`: HTTP client.
-   `provider`: State management.
-   `cached_network_image`: Image caching.
-   `flutter_staggered_grid_view`: Masonry layout.
-   `shared_preferences`: Persist settings.
-   `gallery_saver`: Save images to gallery.
-   `intl`: Localization support.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
