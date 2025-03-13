import 'package:crosswords/screens/register_page.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class LoginPage extends StatelessWidget {
  final VoidCallback onLogin;
  final VoidCallback toggleTheme;
  final VoidCallback onContinueWithoutLogin;
  final bool isDarkMode;

  const LoginPage({
    super.key,
    required this.onLogin,
    required this.onContinueWithoutLogin,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  Future<void> _performLogin(BuildContext context) async {
    try {
      await ApiService.login("testuser", "password123");
      onLogin();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ошибка входа. Проверьте данные.")),
      );
    }
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: [
        IconButton(
          icon: Icon(isDarkMode ? Icons.wb_sunny : Icons.nights_stay, size: 28),
          onPressed: toggleTheme,
        ),
      ],
    );
  }

  ButtonStyle _buttonStyle(BuildContext context) {
    return ElevatedButton.styleFrom(
      backgroundColor: Theme.of(context).primaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
    );
  }

  void _navigateToRegister(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegisterPage(
          onRegisterSuccess: onLogin,
          toggleTheme: toggleTheme,
          isDarkMode: isDarkMode,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.account_circle, size: 120, color: Colors.grey),
              const SizedBox(height: 24),
              const Text(
                'Добро пожаловать в Умный Кропус СМИ',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => _performLogin(context),
                style: _buttonStyle(context),
                child: const Text('Войти',
                    style: TextStyle(fontSize: 20, color: Colors.black)),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _navigateToRegister(context),
                style: _buttonStyle(context),
                child: const Text('Регистрация',
                    style: TextStyle(fontSize: 20, color: Colors.black)),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: onContinueWithoutLogin,
                child: const Text(
                  'Продолжить без регистрации',
                  style: TextStyle(
                      fontSize: 18, decoration: TextDecoration.underline),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
