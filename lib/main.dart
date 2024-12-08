import 'package:bukuhub/edit_profile/edit_profile_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'auth/login_screen.dart';
import 'auth/signup_screen.dart';
import 'category/category_screen.dart';
import 'dashboard/dashboard_screen.dart';
import 'firebase_options.dart';
import 'profile/profile_screen.dart';
import 'search/search_screen.dart';
import 'splash/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme(bool isDarkMode) {
    setState(() {
      _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BukuHub App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 35, 81, 245)),
        useMaterial3: true,
      ),
      themeMode: _themeMode,
      darkTheme: ThemeData.dark(),
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const RegisterPage(),
        '/dashboard': (context) => const HomeScreen(),
        '/explore': (context) => const BookCategoryPage(),
        '/profile': (context) => ProfilePage(
              toggleTheme: _toggleTheme,
              isDarkMode: _themeMode == ThemeMode.dark,
            ),
        '/search': (context) => const SearchScreen(),
        '/edit_profile': (context) => const EditProfilePage()
      },
    );
  }
}
