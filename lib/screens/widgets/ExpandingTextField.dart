import 'package:flutter/material.dart';

class ExpandingTextField extends StatefulWidget {
  final TextEditingController controller;

  const ExpandingTextField({Key? key, required this.controller}) : super(key: key);

  @override
  _ExpandingTextFieldState createState() => _ExpandingTextFieldState();
}

class _ExpandingTextFieldState extends State<ExpandingTextField> {
  final int maxLinesBeforeScroll = 5;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: maxLinesBeforeScroll * 24.0,
        ),
        child: Scrollbar(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: TextField(
              controller: widget.controller,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: "Оставить заметку...",
              ),
            ),
          ),
        ),
      ),
    );
  }
}
