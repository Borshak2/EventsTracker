import 'package:events_tracker/feature/widgets/widgets.dart';
import 'package:flutter/material.dart';

/// Элемент раскрывающегося списка, позволяющий отображать элементы в пользовательском интерфейсе.
class SheetDropdownItem<T> {
  SheetDropdownItem({
    required this.value,
    required this.title,
    this.icon,
  });

  final T value;
  final Widget? icon;
  final String title;
}

/// Виджет, позволяющий выбрать одно значение из нескольких с помощью нижнего листа.
///
/// !!! Если [значения] содержит только 1 элемент, лист не сможет открыться.
class SelectDropdown<T> extends StatelessWidget {
  const SelectDropdown({
    required this.values,
    required this.currentValue,
    required this.onChanged,
    this.sheetTitle,
    this.titleText,
    this.subtitleText,
    this.titleChild,
    this.subtitleChild,
    super.key,
  });

  /// Список значений, которые будут использоваться для выбора [currentValue] с помощью bottom sheet.
  final List<SheetDropdownItem<T>> values;

  /// Текущее значение, которое будет отображаться.
  /// Значение может быть нулевым, что означает, что ничего отображаться не будет.
  final T? currentValue;

  /// Заголовок, который будет отображаться для поля ввода.
  final String? titleText;

  /// Виджет, который можно использовать в качестве заголовка для ввода.
  /// В обычных случаях вы будете использовать [titleText].
  final Widget? titleChild;

  /// Subtitle, который будет отображаться сразу за заголовком.
  final String? subtitleText;

  /// Виджет, который можно использовать для subtitle для ввода.
  /// В обычных случаях вы будете использовать [subtitleText].
  final Widget? subtitleChild;

  /// Обратный вызов, который вызывается, когда пользователь выбирает новый элемент на листе.
  final ValueChanged<T> onChanged;

  /// Заголовок, который используется на отображаемом листе, чтобы сообщить пользователю, что выбрать
  final String? sheetTitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final title = titleChild ??
        (titleText == null
            ? null
            : Text(
                titleText!,
                style: textTheme.titleMedium,
              ));

    final subtitle = subtitleChild ??
        (subtitleText == null
            ? null
            : Text(
                subtitleText!,
                style: textTheme.bodySmall,
              ));

    return PressScaleWidget(
      onPressed: values.length == 1 ? null : () => _openSelectSheet(context),
      child: Column(
        children: [
          if (title != null || subtitle != null) ...[
            Row(
              children: [
                if (title != null) title,
                if (title != null && subtitle != null) const SizedBox(width: 4),
                if (subtitle != null) subtitle,
              ],
            ),
          ],
          Row(
            children: [
              Expanded(
                child: currentValue == null
                    ? const SizedBox.shrink()
                    : _itemBuilder(
                        values.firstWhere((e) => e.value == currentValue),
                      ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.keyboard_arrow_right_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _itemBuilder(
    SheetDropdownItem<T> value, {
    bool isSelected = false,
    VoidCallback? onPressed,
  }) {
    return Builder(
      builder: (context) {
        final style = Theme.of(context).textTheme.bodyMedium;

        return PressScaleWidget(
          onPressed: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                if (value.icon != null) ...[
                  value.icon!,
                  const SizedBox(width: 8),
                ],
                Expanded(child: Text(value.title, style: style)),
                if (isSelected) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.check_rounded),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _openSelectSheet(BuildContext context) {
    showCommonBottomSheet<void>(
      context: context,
      title: sheetTitle,
      body: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            children: values
                .map(
                  (e) => _itemBuilder(
                    e,
                    isSelected: e == currentValue,
                    onPressed: () {
                      Navigator.of(context).pop();
                      onChanged(e.value);
                    },
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }
}
