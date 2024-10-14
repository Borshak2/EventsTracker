import 'package:events_tracker/data/data.dart';
import 'package:events_tracker/feature/widgets/widgets.dart';
import 'package:events_tracker/generated/generated.dart';
import 'package:flutter/material.dart';

/// Вспомогательная функция для подтверждения удаления события.
/// Возвращает false, если пользователь решил удалить событие.
Future<bool> showConfirmRemoveEventSheet(
  BuildContext context,
  EventModelWithStatistic model,
) async {
  final result = await showCommonBottomSheet<bool>(
    context: context,
    title: LocaleKeys.wannaRemoveEvent.tr(),
    body: (_, __) => ConfirmRemoveEventSheet(model: model),
  );

  return result ?? false;
}

class ConfirmRemoveEventSheet extends StatelessWidget {
  const ConfirmRemoveEventSheet({
    required this.model,
    super.key,
  });

  final EventModelWithStatistic model;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: EventColorWidget.medium(color: model.color),
          title: Text(model.eventTitle),
        ),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(LocaleKeys.cancelWord.tr()),
              ),
            ),
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(LocaleKeys.deleteWord.tr()),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
