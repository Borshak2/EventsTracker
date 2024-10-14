import 'package:events_tracker/feature/widgets/widgets.dart';
import 'package:events_tracker/generated/generated.dart';
import 'package:flutter/material.dart';

/// Returns true if screen must be closed
Future<bool?> showVerifyClosingAddEventSheet(BuildContext context) {
  return showCommonBottomSheet<bool>(
    context: context,
    title: LocaleKeys.wannaStopAddingEvent.tr(),
    body: (_, __) => const VerifyClosingAddEventSheet(),
  );
}

class VerifyClosingAddEventSheet extends StatelessWidget {
  const VerifyClosingAddEventSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(LocaleKeys.stopWord.tr()),
          ),
        ),
        Expanded(
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(LocaleKeys.continueWord.tr()),
          ),
        ),
      ],
    );
  }
}
