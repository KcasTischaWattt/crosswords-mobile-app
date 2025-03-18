import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsPage extends StatefulWidget {
  final void Function(ThemeMode) setTheme;
  final Future<void> Function() onLogout;

  const SettingsPage({
    super.key,
    required this.setTheme,
    required this.onLogout,
  });

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool incognitoMode = false;
  bool prioritizeBank = false;
  bool shakeToTransfer = true;

  String get currentThemeName {
    return Theme.of(context).brightness == Brightness.dark ? "Тёмная" : "Светлая";
  }

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
      inactiveTrackColor: theme.bottomNavigationBarTheme.backgroundColor,
      onChanged: onChanged,
    );
  }

  Widget _buildStaticTile(String title, String subtitle, ThemeData theme, {VoidCallback? onTap, bool isSelected = false}) {
    return Material(
      color: isSelected ? theme.primaryColor.withOpacity(0.1) : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: ListTile(
          title: Text(title, style: TextStyle(fontSize: 14)),
          subtitle: subtitle.isNotEmpty ? Text(subtitle, style: TextStyle(color: Colors.grey)) : null,
          trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ),
      ),
    );
  }


  void _showThemeBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildBottomSheetTile("Светлая", () {
                _setTheme("Светлая", ThemeMode.light);
              }),
              _buildBottomSheetTile("Тёмная", () {
                _setTheme("Тёмная", ThemeMode.dark);
              }),
            ],
          ),
        );
      },
    );
  }

  void _setTheme(String mode, ThemeMode newThemeMode) {;
    widget.setTheme(newThemeMode);
    Navigator.pop(context);
  }

  Widget _buildBottomSheetTile(String title, VoidCallback onTap) {
    return ListTile(
      title: Text(title, style: TextStyle(fontSize: 16)),
      onTap: onTap,
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
            _buildStaticTile('Сменить почту', '', theme),
            _buildStaticTile('Сменить пароль', '', theme),
            _buildStaticTile('Язык', 'Русский', theme),
            _buildStaticTile('Тема', currentThemeName, theme, onTap: _showThemeBottomSheet),
          ], cardColor!),

          SizedBox(height: 20),

          _buildSettingsBlock('Уведомления и раассылки', [
            _buildSwitchTile('Разрешить добавлять меня в рассылку', incognitoMode, (value) {
              setState(() => incognitoMode = value);
            }, theme),
            _buildSwitchTile('Разрешить уведомления на почту', prioritizeBank, (value) {
              setState(() => prioritizeBank = value);
            }, theme),
            _buildSwitchTile('Разрешить уведомления в приложении', shakeToTransfer, (value) {
              setState(() => shakeToTransfer = value);
            }, theme),
            _buildStaticTile('Настройки уведомлений', '', theme),
          ], cardColor),
        ],
      ),
    );
  }
}

