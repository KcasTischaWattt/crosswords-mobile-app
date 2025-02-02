import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  final VoidCallback toggleTheme;
  final ValueNotifier<bool> isFavoriteDialogEnabled;

  const SettingsPage({
    Key? key,
    required this.toggleTheme,
    required this.isFavoriteDialogEnabled,
  }) : super(key: key);

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
            ValueListenableBuilder<bool>(
              valueListenable: isFavoriteDialogEnabled,
              builder: (context, value, _) {
                return SwitchListTile(
                  title: const Text('Включить диалог избранного'),
                  subtitle: const Text('Запрашивать подтверждение при добавлении или удалении'),
                  value: value,
                  onChanged: (newValue) {
                    isFavoriteDialogEnabled.value = newValue;  // Обновляем глобальное состояние
                  },
                );
              },
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
          ],
        ),
      ),
    );
  }
}
