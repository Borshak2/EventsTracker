import 'package:flutter/material.dart';

/// Коэффициент масштабирования в процентах
const _defaultScaleRatio = 5.0;

/// {@template press_scale_widget}
/// Виджет, размер которого изменяется при нажатии
/// {@endtemplate}
class PressScaleWidget extends StatefulWidget {
  /// {@macro press_scale_widget}
  const PressScaleWidget({
    required this.child,
    super.key,
    this.onPressed,
    this.radius,
    this.animationDuration = const Duration(milliseconds: 50),
    this.onLongPress,
    this.height,
    this.width,
    this.scaleRatio = _defaultScaleRatio,
  });

  /// Высота виджета
  final double? height;

  /// Ширина виджета
  final double? width;

  /// Виджет, который отображается при нажатии
  final Widget? child;

  ///  Обратный вызов
  final VoidCallback? onPressed;

  ///  Обратный вызов при долгом нажатии
  final VoidCallback? onLongPress;

  /// Радиус эффекта наведения
  final double? radius;

  /// Продолжительность анимации масштабирования, по умолчанию 50 миллисекунд.
  final Duration animationDuration;

  /// Коэффициент масштабирования в процентах, по умолчанию [_defaultScaleRatio]
  final double scaleRatio;

  @override
  PressScaleWidgetState createState() => PressScaleWidgetState();
}

class PressScaleWidgetState extends State<PressScaleWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _doubleAnimation;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    )..addListener(() {
        // ignore: no-empty-block
        setState(() {});
      });
    _doubleAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    assert(
      debugCheckHasMaterial(context),
      'No Material above PressScaleWidget',
    );

    return InkResponse(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      onHighlightChanged: _onHighlightChanged,
      onLongPress: widget.onLongPress,
      onTap: widget.onPressed,
      radius: widget.radius,
      child: Transform.scale(
        // ignore: no-magic-number
        scale: 1.0 - (_doubleAnimation.value * widget.scaleRatio / 100),
        child: SizedBox(
          height: widget.height,
          width: widget.width,
          child: widget.child,
        ),
      ),
    );
  }

  void _onHighlightChanged(bool isPressed) {
    if (isPressed) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }
}
