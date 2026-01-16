import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Wallhaven Flutter'**
  String get appTitle;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search wallpapers...'**
  String get searchHint;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @loginApiKey.
  ///
  /// In en, this message translates to:
  /// **'Login / API Key'**
  String get loginApiKey;

  /// No description provided for @apiKey.
  ///
  /// In en, this message translates to:
  /// **'API Key'**
  String get apiKey;

  /// No description provided for @enterApiKey.
  ///
  /// In en, this message translates to:
  /// **'Enter your Wallhaven API Key'**
  String get enterApiKey;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @enterUsername.
  ///
  /// In en, this message translates to:
  /// **'Enter your Wallhaven username'**
  String get enterUsername;

  /// No description provided for @usernameRequiredForCollections.
  ///
  /// In en, this message translates to:
  /// **'Required to view collections'**
  String get usernameRequiredForCollections;

  /// No description provided for @pleaseEnterUsername.
  ///
  /// In en, this message translates to:
  /// **'Please enter username in settings'**
  String get pleaseEnterUsername;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @purity.
  ///
  /// In en, this message translates to:
  /// **'Purity'**
  String get purity;

  /// No description provided for @sorting.
  ///
  /// In en, this message translates to:
  /// **'Sorting'**
  String get sorting;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @anime.
  ///
  /// In en, this message translates to:
  /// **'Anime'**
  String get anime;

  /// No description provided for @people.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get people;

  /// No description provided for @sfw.
  ///
  /// In en, this message translates to:
  /// **'SFW'**
  String get sfw;

  /// No description provided for @sketchy.
  ///
  /// In en, this message translates to:
  /// **'Sketchy'**
  String get sketchy;

  /// No description provided for @nsfw.
  ///
  /// In en, this message translates to:
  /// **'NSFW'**
  String get nsfw;

  /// No description provided for @dateAdded.
  ///
  /// In en, this message translates to:
  /// **'Date Added'**
  String get dateAdded;

  /// No description provided for @relevance.
  ///
  /// In en, this message translates to:
  /// **'Relevance'**
  String get relevance;

  /// No description provided for @random.
  ///
  /// In en, this message translates to:
  /// **'Random'**
  String get random;

  /// No description provided for @views.
  ///
  /// In en, this message translates to:
  /// **'Views'**
  String get views;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @toplist.
  ///
  /// In en, this message translates to:
  /// **'Toplist'**
  String get toplist;

  /// No description provided for @hot.
  ///
  /// In en, this message translates to:
  /// **'Hot'**
  String get hot;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved!'**
  String get saved;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @resolution.
  ///
  /// In en, this message translates to:
  /// **'Resolution'**
  String get resolution;

  /// No description provided for @size.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get size;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @noWallpapersFound.
  ///
  /// In en, this message translates to:
  /// **'No wallpapers found'**
  String get noWallpapersFound;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @downloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading...'**
  String get downloading;

  /// No description provided for @downloadedTo.
  ///
  /// In en, this message translates to:
  /// **'Downloaded to {path}'**
  String downloadedTo(Object path);

  /// No description provided for @savedToGallery.
  ///
  /// In en, this message translates to:
  /// **'Saved to Gallery!'**
  String get savedToGallery;

  /// No description provided for @webDownloadNotImplemented.
  ///
  /// In en, this message translates to:
  /// **'Web download not implemented'**
  String get webDownloadNotImplemented;

  /// No description provided for @aiArt.
  ///
  /// In en, this message translates to:
  /// **'Ai Art'**
  String get aiArt;

  /// No description provided for @loginReminder.
  ///
  /// In en, this message translates to:
  /// **'Please set your API Key in Settings to access all features.'**
  String get loginReminder;

  /// No description provided for @pleaseLoginFirst.
  ///
  /// In en, this message translates to:
  /// **'Please login first to use this feature'**
  String get pleaseLoginFirst;

  /// No description provided for @removedFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Removed from favorites'**
  String get removedFromFavorites;

  /// No description provided for @addedToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Added to favorites'**
  String get addedToFavorites;

  /// No description provided for @operationFailed.
  ///
  /// In en, this message translates to:
  /// **'Operation failed'**
  String get operationFailed;

  /// No description provided for @cannotOpenLink.
  ///
  /// In en, this message translates to:
  /// **'Cannot open link'**
  String get cannotOpenLink;

  /// No description provided for @shareFailed.
  ///
  /// In en, this message translates to:
  /// **'Share failed'**
  String get shareFailed;

  /// No description provided for @downloadPath.
  ///
  /// In en, this message translates to:
  /// **'Download Path'**
  String get downloadPath;

  /// No description provided for @defaultDownloadsFolder.
  ///
  /// In en, this message translates to:
  /// **'Default (Downloads folder)'**
  String get defaultDownloadsFolder;

  /// No description provided for @tapIconToChange.
  ///
  /// In en, this message translates to:
  /// **'Tap icon to change'**
  String get tapIconToChange;

  /// No description provided for @ratios.
  ///
  /// In en, this message translates to:
  /// **'Ratios'**
  String get ratios;

  /// No description provided for @colors.
  ///
  /// In en, this message translates to:
  /// **'Colors'**
  String get colors;

  /// No description provided for @order.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get order;

  /// No description provided for @topRange.
  ///
  /// In en, this message translates to:
  /// **'Toplist Range'**
  String get topRange;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @asc.
  ///
  /// In en, this message translates to:
  /// **'Ascending'**
  String get asc;

  /// No description provided for @desc.
  ///
  /// In en, this message translates to:
  /// **'Descending'**
  String get desc;

  /// No description provided for @lastDay.
  ///
  /// In en, this message translates to:
  /// **'Last Day'**
  String get lastDay;

  /// No description provided for @last3Days.
  ///
  /// In en, this message translates to:
  /// **'Last 3 Days'**
  String get last3Days;

  /// No description provided for @lastWeek.
  ///
  /// In en, this message translates to:
  /// **'Last Week'**
  String get lastWeek;

  /// No description provided for @lastMonth.
  ///
  /// In en, this message translates to:
  /// **'Last Month'**
  String get lastMonth;

  /// No description provided for @last3Months.
  ///
  /// In en, this message translates to:
  /// **'Last 3 Months'**
  String get last3Months;

  /// No description provided for @last6Months.
  ///
  /// In en, this message translates to:
  /// **'Last 6 Months'**
  String get last6Months;

  /// No description provided for @lastYear.
  ///
  /// In en, this message translates to:
  /// **'Last Year'**
  String get lastYear;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
