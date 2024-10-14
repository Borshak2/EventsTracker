import 'package:events_tracker/feature/widgets/widgets.dart';
import 'package:events_tracker/generated/generated.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';

/// Виджет, позволяющий выбирать цвет с помощью ColorPicker
class ColorPickerWidget extends StatelessWidget {
  const ColorPickerWidget({
    required this.color,
    required this.onSelected,
    super.key,
  });

  final Color color;
  final ValueChanged<Color> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(LocaleKeys.eventColorTitle.tr(), style: Theme.of(context).textTheme.titleMedium),
        Row(
          children: [
            EventColorWidget.big(color: color),
            const SizedBox(width: 8),
            PrimaryTextButton(
              onPressed: () async {
                final newColor = await showColorPickerDialog(
                  context,
                  color,
                  pickersEnabled: {
                    ColorPickerType.wheel: true,
                    ColorPickerType.accent: false,
                    ColorPickerType.primary: false,
                  },
                );

                if (newColor != color) {
                  onSelected(newColor);
                }
              },
              text: LocaleKeys.changeWord.tr(),
            ),
          ],
        ),
      ],
    );
  }
}
