import 'package:flutter/material.dart';

const kButtonHeight = 48.0;

/// Кнопка по умолчанию для приложения
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.text,
    this.onPressed,
    super.key,
  });

  final String text;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        minimumSize: MaterialStateProperty.all(const Size.fromHeight(kButtonHeight)),
        elevation: MaterialStateProperty.all(1),
      ),
      child: Text(text),
    );
  }
}

class PrimaryTextButton extends StatelessWidget {
  const PrimaryTextButton({
    required this.text,
    this.onPressed,
    super.key,
  });

  final String text;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: ButtonStyle(
        elevation: MaterialStateProperty.all(0),
      ),
      child: Text(text),
    );
  }
}
