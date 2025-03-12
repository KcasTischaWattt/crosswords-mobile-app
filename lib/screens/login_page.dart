import 'package:crosswords/screens/articles_page.dart';
import 'package:flutter/material.dart';

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

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      toolbarHeight: 60,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      elevation: 0,
      actions: [
        IconButton(
          icon: Icon(
            isDarkMode ? Icons.wb_sunny : Icons.nights_stay,
            color: Theme.of(context).iconTheme.color,
            size: 28,
          ),
          onPressed: toggleTheme,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.account_circle,
                size: 120,
                color: Colors.grey,
              ),
              const SizedBox(height: 24),
              const SizedBox(
                width: double.infinity,
                child: Text(
                  'Добро пожаловать в Умный Кропус СМИ',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: onLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                ),
                child: const Text(
                  'Войти',
                  style: TextStyle(fontSize: 20, color: Colors.black),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                ),
                child: const Text(
                  'Регистрация',
                  style: TextStyle(fontSize: 20, color: Colors.black),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: onContinueWithoutLogin,
                child: const Text(
                  'Продолжить без регистрации',
                  style: TextStyle(
                    fontSize: 18,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
