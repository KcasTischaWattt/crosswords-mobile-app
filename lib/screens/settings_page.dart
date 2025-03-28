import 'package:crosswords/main.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:crosswords/providers/auth_provider.dart';

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
  bool addToDigest = false;
  bool emailNotifications = false;
  bool mobileNotifications = true;
  bool sideMailNotifications = false;
  bool sideMobileNotifications = false;

  String get currentThemeName {
    return Theme.of(context).brightness == Brightness.dark
        ? "Тёмная"
        : "Светлая";
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

  Widget _buildSettingsBlock(
      String title, List<Widget> children, Color cardColor) {
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

  Widget _buildSwitchTile(
      String title, bool value, Function(bool) onChanged, ThemeData theme) {
    return SwitchListTile(
      title: Text(title, style: TextStyle(fontSize: 14)),
      value: value,
      activeColor: theme.primaryColor,
      inactiveTrackColor: theme.bottomNavigationBarTheme.backgroundColor,
      onChanged: onChanged,
    );
  }

  Widget _buildStaticTile(String title, String subtitle, ThemeData theme,
      {VoidCallback? onTap, bool isSelected = false}) {
    return Material(
      color:
          isSelected ? theme.primaryColor.withOpacity(0.1) : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: ListTile(
          title: Text(title, style: TextStyle(fontSize: 14)),
          subtitle: subtitle.isNotEmpty
              ? Text(subtitle, style: TextStyle(color: Colors.grey))
              : null,
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

  void _setTheme(String mode, ThemeMode newThemeMode) {
    ;
    widget.setTheme(newThemeMode);
    Navigator.pop(context);
  }

  Widget _buildBottomSheetTile(String title, VoidCallback onTap) {
    return ListTile(
      title: Text(title, style: TextStyle(fontSize: 16)),
      onTap: onTap,
    );
  }

  Widget _buildAuthButton(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isAuth = authProvider.isAuthenticated;
    final buttonText = isAuth ? 'Выйти' : 'Войти';

    return Align(
      alignment: Alignment.centerLeft,
      child: ElevatedButton(
        onPressed: () async {
          if (isAuth) {
            await widget.onLogout();
          } else {
            Provider.of<AuthProvider>(context, listen: false)
                .setUnauthenticated();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isAuth ? Theme.of(context).dangerColor : Theme.of(context).primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          buttonText,
          style: const TextStyle(fontSize: 16, color: Colors.black),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor =
        theme.bottomNavigationBarTheme.backgroundColor ?? Colors.grey[900];

    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildSettingsBlock(
              'Общие',
              [
                _buildStaticTile('Сменить почту', '', theme),
                _buildStaticTile('Сменить пароль', '', theme),
                _buildStaticTile('Язык', 'Русский', theme),
                _buildStaticTile('Тема', currentThemeName, theme,
                    onTap: _showThemeBottomSheet),
              ],
              cardColor!),
          SizedBox(height: 20),
          _buildSettingsBlock(
              'Уведомления и раассылки',
              [
                _buildSwitchTile(
                    'Разрешить добавлять меня в рассылку', addToDigest,
                    (value) {
                  setState(() => addToDigest = value);
                }, theme),
                AnimatedSwitcher(
                  duration: Duration(milliseconds: 300),
                  child: addToDigest
                      ? Column(
                          key: ValueKey<bool>(addToDigest),
                          children: [
                            _buildSwitchTile(
                                'Разрешить сторонние уведомления на почту',
                                sideMailNotifications, (value) {
                              setState(() => sideMailNotifications = value);
                            }, theme),
                            _buildSwitchTile(
                                'Разрешить сторонние мобильные уведомления',
                                sideMobileNotifications, (value) {
                              setState(() => sideMobileNotifications = value);
                            }, theme),
                          ],
                        )
                      : SizedBox.shrink(),
                ),
                _buildSwitchTile(
                    'Разрешить уведомления на почту', emailNotifications,
                    (value) {
                  setState(() => emailNotifications = value);
                }, theme),
                _buildSwitchTile(
                    'Разрешить мобильные уведомления', mobileNotifications,
                    (value) {
                  setState(() => mobileNotifications = value);
                }, theme),
                _buildStaticTile('Настройки уведомлений', '', theme),
              ],
              cardColor),
          const SizedBox(height: 10),
          _buildAuthButton(context),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
