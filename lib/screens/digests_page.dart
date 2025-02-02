import 'package:flutter/material.dart';

class DigestsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Дайджесты')),
      body: Center(child: Text('Список доступных дайджестов', style: TextStyle(fontSize: 18))),
    );
  }
}