import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  static const String _apiKeyKey = 'api_key';
  static const String _usernameKey = 'username';
  static const String _languageKey = 'language_code';
  static const String _themeKey = 'theme_mode';
  static const String _downloadPathKey = 'download_path';

  String _apiKey = '';
  String _username = '';
  Locale _locale = const Locale('en');
  ThemeMode _themeMode = ThemeMode.system;
  String? _downloadPath;

  String get apiKey => _apiKey;
  String get username => _username;

  bool _initialized = false;
  bool get isInitialized => _initialized;
  Locale get locale => _locale;
  ThemeMode get themeMode => _themeMode;
  String? get downloadPath => _downloadPath;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _apiKey = prefs.getString(_apiKeyKey) ?? '';
    _username = prefs.getString(_usernameKey) ?? '';
    String? langCode = prefs.getString(_languageKey);
    if (langCode != null) {
      _locale = Locale(langCode);
    }
    int? themeIndex = prefs.getInt(_themeKey);
    if (themeIndex != null && themeIndex >= 0 && themeIndex < ThemeMode.values.length) {
      _themeMode = ThemeMode.values[themeIndex];
    }
    _downloadPath = prefs.getString(_downloadPathKey);
    _initialized = true;
    notifyListeners();
  }

  Future<void> setApiKey(String key) async {
    _apiKey = key;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyKey, key);
    notifyListeners();
  }

  Future<void> setUsername(String username) async {
    _username = username;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usernameKey, username);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, locale.languageCode);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
    notifyListeners();
  }

  Future<void> setDownloadPath(String? path) async {
    _downloadPath = path;
    final prefs = await SharedPreferences.getInstance();
    if (path != null) {
      await prefs.setString(_downloadPathKey, path);
    } else {
      await prefs.remove(_downloadPathKey);
    }
    notifyListeners();
  }
}
