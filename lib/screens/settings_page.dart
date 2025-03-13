import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  final VoidCallback toggleTheme;
  final Future<void> Function() onLogout;

  const SettingsPage({
    super.key,
    required this.toggleTheme,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
        backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Настройки приложения',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: toggleTheme,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Переключить тему', style: TextStyle(color: Colors.black)),
            ),
            ElevatedButton(
              onPressed: () async {
                await onLogout(); // Ждём завершения выхода
              },
              child: const Text("Выйти"),
            ),
          ],
        ),
      ),
    );
  }
}
