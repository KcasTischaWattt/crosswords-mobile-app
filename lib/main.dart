import 'package:crosswords/providers/auth_provider.dart';
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
import 'screens/auth_page.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  ApiService.initializeInterceptors();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ArticleProvider()),
        ChangeNotifierProvider(create: (_) => DigestProvider()),
        ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
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
  bool? showMainApp;
  ThemeMode _themeMode = ThemeMode.dark;

  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => Provider.of<AuthProvider>(context, listen: false).checkAuth());
  }

  Future<void> _checkAuthStatus() async {
    await Provider.of<AuthProvider>(context, listen: false).checkAuth();
    setState(() {
      showMainApp =
          Provider.of<AuthProvider>(context, listen: false).isAuthenticated;
    });
  }

  void _onContinueWithoutLogin() {
    setState(() {
      Provider.of<AuthProvider>(context, listen: false).setUnauthenticated();
      showMainApp = true;
    });
  }

  Future<void> _onLogout() async {
    await Provider.of<AuthProvider>(context, listen: false).logout();
    setState(() {
      showMainApp = false;
    });
  }

  void _setTheme(ThemeMode newThemeMode) {
    setState(() {
      _themeMode = newThemeMode;
    });
  }

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          theme: _buildLightTheme(),
          darkTheme: _buildDarkTheme(),
          themeMode: _themeMode,
          routes: {
            '/main': (context) => MainApp(
              setTheme: _setTheme,
              onLogout: _onLogout,
              isAuthenticated: authProvider.isAuthenticated,
            ),
            '/auth': (context) => AuthPage(
              setLogin: _checkAuthStatus,
              onContinueWithoutLogin: _onContinueWithoutLogin,
              toggleTheme: _toggleTheme,
              isDarkMode: _themeMode == ThemeMode.dark,
            ),
          },
          home: authProvider.isAuthenticated
              ? MainApp(
            setTheme: _setTheme,
            onLogout: _onLogout,
            isAuthenticated: authProvider.isAuthenticated,
          )
              : AuthPage(
            setLogin: _checkAuthStatus,
            onContinueWithoutLogin: _onContinueWithoutLogin,
            toggleTheme: _toggleTheme,
            isDarkMode: _themeMode == ThemeMode.dark,
          ),
        );
      },
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
  final void Function(ThemeMode) setTheme;
  final bool isAuthenticated;
  final Future<void> Function() onLogout;

  const MainApp({
    super.key,
    required this.setTheme,
    required this.isAuthenticated,
    required this.onLogout,
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
        isAuthenticated: widget.isAuthenticated,
      ),
      DigestsPage(),
      NotificationsPage(),
      SettingsPage(
        setTheme: widget.setTheme,
        onLogout: widget.onLogout,
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
