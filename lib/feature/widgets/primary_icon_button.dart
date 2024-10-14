import 'package:flutter/material.dart';

enum PrimaryIconButtonSize {
  small,
  medium;

  double get iconSize {
    return switch (this) {
      PrimaryIconButtonSize.small => 20.0,
      PrimaryIconButtonSize.medium => 24.0,
    };
  }

  EdgeInsets get padding {
    return switch (this) {
      PrimaryIconButtonSize.small => const EdgeInsets.all(4),
      PrimaryIconButtonSize.medium => const EdgeInsets.all(8),
    };
  }

  BoxConstraints get constraints {
    return switch (this) {
      PrimaryIconButtonSize.small => const BoxConstraints.expand(height: 28, width: 28),
      PrimaryIconButtonSize.medium => const BoxConstraints.expand(height: 40, width: 40),
    };
  }
}

/// Класс по умолчанию, который отображает IconButton в приложении
class PrimaryIconButton extends StatelessWidget {
  const PrimaryIconButton({
    required this.icon,
    this.size = PrimaryIconButtonSize.medium,
    this.onPressed,
    super.key,
  });

  final Widget icon;
  final VoidCallback? onPressed;

  final PrimaryIconButtonSize size;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        canRequestFocus: false,
        onTap: onPressed,
        borderRadius: BorderRadius.circular(90),
        child: Padding(
          padding: size.padding,
          child: IconTheme(
            data: IconTheme.of(context).copyWith(
              size: size.iconSize,
              color: onPressed == null ? Colors.grey[400] : null,
            ),
            child: icon,
          ),
        ),
      ),
    );
  }
}
