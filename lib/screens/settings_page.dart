import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  final VoidCallback toggleTheme;
  final Future<void> Function() onLogout;

  const SettingsPage({
    super.key,
    required this.toggleTheme,
    required this.onLogout,
  });

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  AppBar _buildAppBar() {
    return AppBar(
      toolbarHeight: 60,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shadowColor: Colors.transparent,
      title: const Text(
        'Настройки',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
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
              onPressed: widget.toggleTheme,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Переключить тему',
                  style: TextStyle(color: Colors.black)),
            ),
            ElevatedButton(
              onPressed: () async {
                await widget.onLogout();
              },
              child: const Text("Выйти"),
            ),
          ],
        ),
      ),
    );
  }
}
