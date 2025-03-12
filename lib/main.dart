import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/article_provider.dart';
import 'providers/digest_provider.dart';
import 'providers/subscription_provider.dart';
import 'screens/articles_page.dart';
import 'screens/digests_page.dart';
import 'screens/notifications_page.dart';
import 'screens/settings_page.dart';
import 'screens/login_page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ArticleProvider()),
        ChangeNotifierProvider(create: (_) => DigestProvider()),
        ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isAuthenticated = false;
  bool isDarkMode = true;
  final ValueNotifier<bool> isFavoriteDialogEnabled = ValueNotifier(true);

  void _login() {
    setState(() {
      isAuthenticated = true;
    });
  }

  void _toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        primaryColor: const Color(0xFFFFD700),
        secondaryHeaderColor: const Color(0xFF517ECF),
        textTheme: GoogleFonts.latoTextTheme()
            .apply(
              bodyColor: Colors.black,
              displayColor: Colors.black,
            )
            .copyWith(
              bodyLarge: TextStyle(fontSize: 18),
              bodyMedium: TextStyle(fontSize: 16),
              bodySmall: TextStyle(fontSize: 14),
            ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFFFFFFFF),
          selectedItemColor: Color(0xFF474389),
          unselectedItemColor: Colors.grey,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: const Color(0xFFFFD700),
        secondaryHeaderColor: const Color(0xFF3E63A0),
        textTheme: GoogleFonts.latoTextTheme()
            .apply(
              bodyColor: Colors.white,
              displayColor: Colors.white,
            )
            .copyWith(
              bodyLarge: TextStyle(fontSize: 18),
              bodyMedium: TextStyle(fontSize: 16),
              bodySmall: TextStyle(fontSize: 14),
            ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1F1F1F),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
        ),
      ),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: isAuthenticated
          ? MainApp(
              toggleTheme: _toggleTheme,
              isFavoriteDialogEnabled: isFavoriteDialogEnabled,
              isAuthenticated: isAuthenticated,
            )
          : LoginPage(
              onLogin: _login,
              toggleTheme: _toggleTheme,
              isDarkMode: isDarkMode),
    );
  }
}

class MainApp extends StatefulWidget {
  final bool isAuthenticated;
  final VoidCallback toggleTheme;
  final ValueNotifier<bool> isFavoriteDialogEnabled;

  const MainApp({
    super.key,
    required this.isAuthenticated,
    required this.toggleTheme,
    required this.isFavoriteDialogEnabled,
  });

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      ArticlesPage(
        isFavoriteDialogEnabled: widget.isFavoriteDialogEnabled.value,
        isAuthenticated: widget.isAuthenticated,
      ),
      DigestsPage(),
      NotificationsPage(),
      SettingsPage(
        toggleTheme: widget.toggleTheme,
        isFavoriteDialogEnabled: widget.isFavoriteDialogEnabled,
      ),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedFontSize: 14,
        unselectedFontSize: 12,
        iconSize: 24,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: 'Статьи',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Дайджесты',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Уведомления',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Настройки',
          ),
        ],
      ),
    );
  }
}
