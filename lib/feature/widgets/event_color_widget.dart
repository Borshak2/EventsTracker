import 'package:events_tracker/data/data.dart';
import 'package:flutter/widgets.dart';

/// Простой виджет, отображающий цвет события
class EventColorWidget extends StatelessWidget {
  const EventColorWidget.small({
    required this.color,
    super.key,
  }) : size = 10;

  const EventColorWidget.medium({
    required this.color,
    super.key,
  }) : size = 16;

  const EventColorWidget.big({
    required this.color,
    super.key,
  }) : size = 20;

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: color.eventGradient,
        border: color.eventBorder,
      ),
    );
  }
}
