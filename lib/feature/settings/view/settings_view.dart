import 'package:events_tracker/data/data.dart';
import 'package:events_tracker/feature/settings/settings.dart';
import 'package:flutter/material.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({
    required this.events,
    super.key,
  });

  final List<EventModelWithStatistic> events;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const AddEventButton();
    }

    return ListView.separated(
      itemCount: events.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (_, index) {
        final event = events[index];
        return EventAndTasksSettingsWidget(
          key: Key(event.id),
          event: event,
        );
      },
    );
  }
}
