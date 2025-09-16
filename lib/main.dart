import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:imagebook/core/auth/pages/wrapper.dart';
import 'package:imagebook/database/firebase_options.dart';
import 'package:imagebook/theme/dark/darkTheme.dart';
import 'package:imagebook/theme/light/lightTheme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Pass platform-specific options
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _setThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ImageBook',
      theme: LightTheme.lightTheme,
      darkTheme: DarkTheme.darkTheme,
      themeMode: _themeMode,
      home: const Wrapper(),
    );
  }
}
