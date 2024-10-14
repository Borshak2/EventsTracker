import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

const dateTimeJsonConverter = DateTimeJsonConverter();
const colorJsonConverter = ColorJsonConverter();

class DateTimeJsonConverter extends JsonConverter<DateTime, int> {
  const DateTimeJsonConverter();

  @override
  DateTime fromJson(int json) => DateTime.fromMillisecondsSinceEpoch(json);

  @override
  int toJson(DateTime object) => object.millisecondsSinceEpoch;
}

class ColorJsonConverter extends JsonConverter<Color, int> {
  const ColorJsonConverter();

  @override
  Color fromJson(int json) => Color(json);

  @override
  int toJson(Color object) => object.value;
}

extension ColorX on Color {
  /// Цвет фона события, полученного из этого
  Color get eventBackgroundColor {
    return withOpacity(0.2);
  }

  /// Цвет панели приложений, взятый из этого
  Color get evenAppBarColor {
    return withOpacity(0.5);
  }

  /// Граница этого цвета в <EventColorWidget>
  Border get eventBorder {
    final hsl = HSLColor.fromColor(this);
    final hslLight = hsl.withLightness((hsl.lightness - 0.1).clamp(0.0, 1.0));

    return Border.all(color: hslLight.toColor());
  }

  /// Градиент, полученный из этого цвета для <EventColorWidget>
  Gradient get eventGradient {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      stops: const [0, 0.3, 0.6, 1],
      colors: [
        withOpacity(0.4),
        withOpacity(0.6),
        withOpacity(0.8),
        this,
      ],
    );
  }
}

extension IterableX<T> on Iterable<T> {
  /// Разделяем каждый элемент списка [разделителем].
  /// Обычно используется в виджетах.
  List<T> separated(T separator) {
    final res = <T>[];
    final it = iterator;

    if (it.moveNext()) {
      res.add(it.current);
    }

    while (it.moveNext()) {
      res.add(separator);
      res.add(it.current);
    }

    return res;
  }
}
