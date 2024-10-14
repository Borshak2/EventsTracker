import 'package:events_tracker/feature/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Виджет, позволяющий вводить целое значение с помощью кнопок увеличения/уменьшения
class AmountInputWidget extends StatelessWidget {
  const AmountInputWidget({
    required this.increaseCallback,
    required this.decreaseCallback,
    this.controller,
    this.focus,
    this.title,
    this.subtitle,
    this.hintText,
    this.textInputAction = TextInputAction.done,
    super.key,
  });

  final TextEditingController? controller;
  final FocusNode? focus;
  final String? title;
  final String? subtitle;
  final String? hintText;
  final TextInputAction textInputAction;

  /// Уменьшение или увеличение может быть нулевым, если условие не удовлетворяет вашему случаю
  final VoidCallback? increaseCallback;
  final VoidCallback? decreaseCallback;

  @override
  Widget build(BuildContext context) {
    return InputWidget(
      focusNode: focus,
      controller: controller,
      textInputAction: textInputAction,
      title: title,
      subtitle: subtitle,
      hintText: hintText,
      inputFormatters: [
        FilteringTextInputFormatter.deny(RegExp(r'\s')),
        FilteringTextInputFormatter.allow(RegExp('[0-9]')),
      ],
      action: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PrimaryIconButton(
            onPressed: increaseCallback,
            icon: const Icon(Icons.arrow_drop_up_outlined),
            size: PrimaryIconButtonSize.small,
          ),
          PrimaryIconButton(
            onPressed: decreaseCallback,
            icon: const Icon(Icons.arrow_drop_down_outlined),
            size: PrimaryIconButtonSize.small,
          ),
        ],
      ),
    );
  }
}
