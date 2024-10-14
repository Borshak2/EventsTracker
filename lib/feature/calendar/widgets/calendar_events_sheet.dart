import 'package:events_tracker/data/data.dart';
import 'package:events_tracker/feature/calendar/calendar.dart';
import 'package:events_tracker/feature/widgets/widgets.dart';
import 'package:events_tracker/generated/generated.dart';
import 'package:flutter/material.dart';

final eventDayFormatterOtherYear = DateFormat('dd MMM yyyy');
final eventDayFormatterThatYear = DateFormat('dd MMM');

String formatTitleForDate(DateTime date) =>
    (date.year == DateTime.now().year ? eventDayFormatterThatYear : eventDayFormatterOtherYear)
        .format(date);

/// Вспомогательная функция для отображения [CalendarEventsSheet]
Future<void> showCalendarEventsSheet({
  required BuildContext context,
  required CalendarDayStatistics data,
}) {
  return showCommonBottomSheet<void>(
    context: context,
    title: LocaleKeys.activitiesFor.tr(args: [
      formatTitleForDate(data.date),
    ]),
    titleAction: Builder(
      builder: (context) {
        return PrimaryIconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            Navigator.of(context).pop();
            showCalendarSelectActivitySheet(context: context, date: data.date);
          },
        );
      },
    ),
    body: (context, scrollController) => CalendarEventsSheet(
      data: data,
      controller: scrollController,
    ),
  );
}

/// Лист, позволяющий просматривать действия за определенный день
class CalendarEventsSheet extends StatelessWidget {
  const CalendarEventsSheet({
    required this.data,
    required this.controller,
    super.key,
  });

  final CalendarDayStatistics data;
  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: controller,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: data.allTasks.map(_taskItem).toList(),
      ),
    );
  }

  Widget _taskItem(CalendarDayTaskStatistics activity) {
    return Builder(builder: (context) {
      return ListTile(
        contentPadding: EdgeInsets.zero,
        leading: EventColorWidget.medium(color: activity.eventColor),
        title: Text(
          activity.taskName,
        ),
        subtitle: Text(
          LocaleKeys.taskCompletedForDayWithCountAndPercent.tr(
            args: [
              activity.completedInDay.toString(),
              activity.completedForDayPercent.toString(),
            ],
          ),
        ),
      );
    });
  }
}
