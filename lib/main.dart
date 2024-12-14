import 'package:final_project/screens/welcome_screen.dart';
import 'package:final_project/utils/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(ChangeNotifierProvider(
      create: (context) => AppState(), child: const MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Final Project',
      theme: ThemeData(
          colorScheme: const ColorScheme(
            primary: Colors.blue,
            onPrimary: Colors.white,
            secondary: Colors.blueAccent,
            onSecondary: Colors.pink,
            background: Colors.white,
            onBackground: Colors.black,
            surface: Colors.lightBlue,
            onSurface: Colors.black,
            brightness: Brightness.light,
            error: Colors.red,
            onError: Colors.white,
          ),
          textTheme: const TextTheme(
            displayLarge: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            displayMedium: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            headlineSmall: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
            bodyLarge: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.normal,
              color: Colors.black,
            ),
            bodyMedium: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: Colors.black,
            ),
            bodySmall: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: Colors.black,
            ),
          )),
      home: const WelcomeScreen(),
    );
  }
}
