import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {
  final VoidCallback onPrimaryPressed;
  final VoidCallback onSecondaryPressed;
  final String primaryText;
  final String secondaryText;

  const ActionButtons({
    super.key,
    required this.onPrimaryPressed,
    required this.onSecondaryPressed,
    required this.primaryText,
    required this.secondaryText,
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
            onPressed: onPrimaryPressed,
            child: Text(primaryText, style: TextStyle(fontSize: 18, color: Colors.black)),
          ),
        ),
        const SizedBox(width: 12),
        TextButton(
          onPressed: onSecondaryPressed,
          child: Text(secondaryText, style: TextStyle(fontSize: 16)),
        ),
      ],
    );
  }
}