import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Уведомления')),
      body: Center(child: Text('Ваши уведомления', style: TextStyle(fontSize: 18))),
    );
  }
}
