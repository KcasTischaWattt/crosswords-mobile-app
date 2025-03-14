import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RegisterPage extends StatefulWidget {
  final Future<void> Function() onRegisterSuccess;
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const RegisterPage({
    super.key,
    required this.onRegisterSuccess,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;
  String? _errorMessage;

  Future<void> _performRegistration() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      await ApiService.register(
        _nameController.text,
        _surnameController.text,
        _usernameController.text,
        _emailController.text,
        _passwordController.text,
      );

      await widget.onRegisterSuccess();
    } catch (e) {
      setState(() {
        _errorMessage = "Ошибка регистрации. Проверьте данные.";
      });
    }

    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.wb_sunny : Icons.nights_stay, size: 28),
            onPressed: widget.toggleTheme,
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_add, size: 100, color: Colors.grey),
              const SizedBox(height: 24),
              const Text(
                'Регистрация',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Ваше Имя"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _surnameController,
                decoration: const InputDecoration(labelText: "Ваша Фамилия"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: "Имя пользователя"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Пароль"),
              ),
              const SizedBox(height: 20),
              if (_errorMessage != null) Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _loading ? null : _performRegistration,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _loading ? const CircularProgressIndicator() : const Text('Зарегистрироваться', style: TextStyle(fontSize: 18, color: Colors.black)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
