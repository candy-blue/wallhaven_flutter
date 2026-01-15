import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/wallpaper_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/home_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProxyProvider<SettingsProvider, WallpaperProvider>(
          create: (_) => WallpaperProvider(),
          update: (_, settings, wp) {
            final provider = wp ?? WallpaperProvider();
            // 只有在设置加载完成后才根据 API Key 同步登录状态，避免空 API Key 触发错误
            if (settings.isInitialized) {
              provider.syncApiKey(settings.apiKey);
            }
            return provider;
          },
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return MaterialApp(
            title: 'Wallhaven Flutter',
            theme: ThemeData(
              brightness: Brightness.light,
              primarySwatch: Colors.blue,
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              primaryColor: const Color(0xFF66BB6A), // Light Green
              colorScheme: const ColorScheme.dark(
                primary: Color(0xFF66BB6A),
                secondary: Color(0xFF66BB6A),
                surface: Color(0xFF2B3238), // Drawer/Card background
              ),
              scaffoldBackgroundColor: const Color(0xFF1E2327), // Main background
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF2B3238),
                elevation: 0,
              ),
              drawerTheme: const DrawerThemeData(
                backgroundColor: Color(0xFF2B3238),
              ),
              cardColor: const Color(0xFF2B3238),
              useMaterial3: true,
            ),
            themeMode: settings.themeMode,
            locale: settings.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('zh'),
            ],
            home: const HomeScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
