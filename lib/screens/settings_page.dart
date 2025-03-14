import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
  bool hideStories = true;
  bool incognitoMode = false;
  bool prioritizeBank = false;
  bool shakeToTransfer = true;

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

  Widget _buildSettingsBlock(String title, List<Widget> children, Color cardColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged, ThemeData theme) {
    return SwitchListTile(
      title: Text(title, style: TextStyle(fontSize: 14)),
      value: value,
      activeColor: theme.primaryColor,
      inactiveTrackColor: Colors.grey,
      onChanged: onChanged,
    );
  }

  Widget _buildStaticTile(String title, String subtitle, ThemeData theme) {
    return ListTile(
      title: Text(title, style: TextStyle(fontSize: 14)),
      subtitle: subtitle.isNotEmpty ? Text(subtitle, style: TextStyle(color: Colors.grey)) : null,
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.bottomNavigationBarTheme.backgroundColor ?? Colors.grey[900];

    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildSettingsBlock('Общие', [
            _buildSwitchTile('Скрывать истории после просмотра', hideStories, (value) {
              setState(() => hideStories = value);
            }, theme),
            _buildStaticTile('Автообновление', 'Включено', theme),
            _buildStaticTile('Язык', 'Русский', theme),
            _buildStaticTile('Тема', 'Как в системе', theme),
          ], cardColor!),

          SizedBox(height: 20),

          _buildSettingsBlock('Контакты и переводы', [
            _buildSwitchTile('Режим инкогнито', incognitoMode, (value) {
              setState(() => incognitoMode = value);
            }, theme),
            _buildSwitchTile('Сделать Т-Банк приоритетным в СБП', prioritizeBank, (value) {
              setState(() => prioritizeBank = value);
            }, theme),
            _buildSwitchTile('Переводы по тряске телефона', shakeToTransfer, (value) {
              setState(() => shakeToTransfer = value);
            }, theme),
            _buildStaticTile('Переводы себе между банками', '', theme),
          ], cardColor),
        ],
      ),
    );
  }
}

