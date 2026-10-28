import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';
import 'services/notification_service.dart';
import 'services/recurring_service.dart';
import 'services/task_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  await RecurringService.generateRecurringTasks();
  final themeMode = await TaskStorage.loadThemeMode();
  runApp(TugasKuApp(initialThemeMode: themeMode));
}

class TugasKuApp extends StatefulWidget {
  final ThemeMode initialThemeMode;
  const TugasKuApp({super.key, required this.initialThemeMode});

  // ignore: library_private_types_in_public_api
  static _TugasKuAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_TugasKuAppState>();

  @override
  State<TugasKuApp> createState() => _TugasKuAppState();
}

class _TugasKuAppState extends State<TugasKuApp> {
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.initialThemeMode;
  }

  void setThemeMode(ThemeMode mode) {
    setState(() => _themeMode = mode);
    TaskStorage.saveThemeMode(mode);
  }

  ThemeMode get themeMode => _themeMode;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TugasKu',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F8FC),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF7F8FC),
          foregroundColor: Color(0xFF1E1E2E),
          elevation: 0,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF6C63FF),
          foregroundColor: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF1E1E2E),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E2E),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF6C63FF),
          foregroundColor: Colors.white,
        ),
        cardTheme: const CardThemeData(
          color: Color(0xFF2A2A3E),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
