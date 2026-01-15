// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Wallhaven Flutter';

  @override
  String get searchHint => 'Search wallpapers...';

  @override
  String get settings => 'Settings';

  @override
  String get loginApiKey => 'Login / API Key';

  @override
  String get apiKey => 'API Key';

  @override
  String get enterApiKey => 'Enter your Wallhaven API Key';

  @override
  String get save => 'Save';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get categories => 'Categories';

  @override
  String get purity => 'Purity';

  @override
  String get sorting => 'Sorting';

  @override
  String get general => 'General';

  @override
  String get anime => 'Anime';

  @override
  String get people => 'People';

  @override
  String get sfw => 'SFW';

  @override
  String get sketchy => 'Sketchy';

  @override
  String get nsfw => 'NSFW';

  @override
  String get dateAdded => 'Date Added';

  @override
  String get relevance => 'Relevance';

  @override
  String get random => 'Random';

  @override
  String get views => 'Views';

  @override
  String get favorites => 'Favorites';

  @override
  String get toplist => 'Toplist';

  @override
  String get hot => 'Hot';

  @override
  String get saved => 'Saved!';

  @override
  String get download => 'Download';

  @override
  String get resolution => 'Resolution';

  @override
  String get size => 'Size';

  @override
  String get category => 'Category';

  @override
  String get noWallpapersFound => 'No wallpapers found';

  @override
  String get error => 'Error';

  @override
  String get downloading => 'Downloading...';

  @override
  String downloadedTo(Object path) {
    return 'Downloaded to $path';
  }

  @override
  String get savedToGallery => 'Saved to Gallery!';

  @override
  String get webDownloadNotImplemented => 'Web download not implemented';

  @override
  String get aiArt => 'Ai Art';

  @override
  String get loginReminder =>
      'Please set your API Key in Settings to access all features.';

  @override
  String get pleaseLoginFirst => 'Please login first to use this feature';

  @override
  String get removedFromFavorites => 'Removed from favorites';

  @override
  String get addedToFavorites => 'Added to favorites';

  @override
  String get operationFailed => 'Operation failed';

  @override
  String get cannotOpenLink => 'Cannot open link';

  @override
  String get shareFailed => 'Share failed';

  @override
  String get downloadPath => 'Download Path';

  @override
  String get defaultDownloadsFolder => 'Default (Downloads folder)';

  @override
  String get tapIconToChange => 'Tap icon to change';
}
