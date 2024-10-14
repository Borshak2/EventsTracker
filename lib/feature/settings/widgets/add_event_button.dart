import 'package:events_tracker/app/router/router.dart';
import 'package:events_tracker/generated/generated.dart';
import 'package:flutter/material.dart';

/// Кнопка, позволяющая перейти к экрану добавления событий
class AddEventButton extends StatelessWidget {
  const AddEventButton({
    this.callbackAction,
    super.key,
  });

  final ValueChanged<BuildContext>? callbackAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            LocaleKeys.noEvents.tr(),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              callbackAction?.call(context);

              AddEventRoute().go(context);
            },
            child: Text(LocaleKeys.addEvent.tr()),
          ),
        ],
      ),
    );
  }
}
