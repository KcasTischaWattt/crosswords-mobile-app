import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {
  final VoidCallback onCreate;
  final VoidCallback onReset;
  final String messageOnCreate;
  final String messageOnReset;

  const ActionButtons({
    super.key,
    required this.onCreate,
    required this.onReset,
    required this.messageOnCreate,
    required this.messageOnReset,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: onCreate,
            child: Text(messageOnCreate, style: TextStyle(fontSize: 18, color: Colors.black)),
          ),
        ),
        const SizedBox(width: 12),
        TextButton(
          onPressed: onReset,
          child: Text(messageOnReset, style: TextStyle(fontSize: 16)),
        ),
      ],
    );
  }
}