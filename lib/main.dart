import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/api_service.dart';
import 'providers/article_provider.dart';
import 'providers/digest_provider.dart';
import 'providers/subscription_provider.dart';
import 'screens/articles_page.dart';
import 'screens/digests_page.dart';
import 'screens/notifications_page.dart';
import 'screens/settings_page.dart';
import 'screens/login_page.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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
  bool? isAuthenticated;
  bool isDarkMode = true;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    setState(() => isAuthenticated = null);
    bool authStatus = await ApiService.checkAuth();
    setState(() => isAuthenticated = authStatus);
  }

  void _onLoginSuccess() {
    setState(() => isAuthenticated = true);
  }

  void _onLogout() {
    setState(() => isAuthenticated = false);
  }

  void _toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: isAuthenticated == null
          ? const Scaffold(body: Center(child: CircularProgressIndicator())) // Ожидание загрузки
          : isAuthenticated!
          ? MainApp(toggleTheme: _toggleTheme)
          : LoginPage(
        onLogin: _checkAuthStatus,
        onContinueWithoutLogin: () {
          setState(() => isAuthenticated = false);
        },
        toggleTheme: _toggleTheme,
        isDarkMode: isDarkMode,
      ),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      primaryColor: const Color(0xFFFFD700),
      secondaryHeaderColor: const Color(0xFF517ECF),
      textTheme: GoogleFonts.latoTextTheme().apply(
        bodyColor: Colors.black,
        displayColor: Colors.black,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFFFFFFFF),
        selectedItemColor: Color(0xFF474389),
        unselectedItemColor: Colors.grey,
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF121212),
      primaryColor: const Color(0xFFFFD700),
      secondaryHeaderColor: const Color(0xFF3E63A0),
      textTheme: GoogleFonts.latoTextTheme().apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1F1F1F),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}


class MainApp extends StatefulWidget {
  final VoidCallback toggleTheme;

  const MainApp({
    super.key,
    required this.toggleTheme,
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
        isAuthenticated: true,
      ),
      DigestsPage(),
      NotificationsPage(),
      SettingsPage(
        toggleTheme: widget.toggleTheme,
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
