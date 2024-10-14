import 'dart:convert';

import 'package:events_tracker/app/services/storage/storage.dart';
import 'package:events_tracker/data/data.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/subjects.dart';

const _calendarActivitiesKey = 'calendarActivities';

/// Хранилище календаря, которое хранит информацию о действиях, которые пользователь отметил в календаре
/// для определенных событий.
@singleton
class CalendarActivitiesStorage {
  final SharedWrapper shared;

  CalendarActivitiesStorage({required this.shared});

  @PostConstruct()
  void init() {
    final activities = shared.getString(_calendarActivitiesKey);

    if (activities != null) {
      final jsonList = (jsonDecode(activities) as List<dynamic>).cast<Map<String, dynamic>>();

      _calendarActivitiesSubject.add(
        Map.fromEntries(
          jsonList.map(
            (e) {
              final c = CalendarDayActivities.fromJson(e);
              return MapEntry(c.date, c);
            },
          ),
        ),
      );
    } else {
      _calendarActivitiesSubject.add({});
    }
  }

  final _calendarActivitiesSubject = BehaviorSubject<Map<DateTime, CalendarDayActivities>>();

  /// Получить поток доступных активностей в календаре.
  Stream<Map<DateTime, CalendarDayActivities>> get calendarActivitiesStream =>
      _calendarActivitiesSubject;

  /// Получить текущие доступные действия календаря
  Map<DateTime, CalendarDayActivities> get calendarActivities => _calendarActivitiesSubject.value;

  /// Найти и увеличить или создать активность для [eventId]+[taskId] на день [date], увеличив её количество
  /// на [increaseCount].
  Future<void> increaseDayActivity({
    required String eventId,
    required String taskId,
    required DateTime date,
    int increaseCount = 1,
  }) async {
    final activities = calendarActivities;
    date = getPureDate(date);
    final dayActivity = activities[date];

    // no activity for this date, create it
    if (dayActivity == null) {
      activities[date] = CalendarDayActivities(
        date: date,
        tasks: [
          DayActivity(
            eventId: eventId,
            taskId: taskId,
            completedCount: increaseCount,
          ),
        ],
      );
    } else {
      final tasks = List<DayActivity>.from(dayActivity.tasks);
      final dayTasksIndex = tasks.indexWhere((t) => t.eventId == eventId && t.taskId == taskId);

      // никаких действий по этому событию в этот день
      if (dayTasksIndex == -1) {
        activities[date] = dayActivity.copyWith(
          tasks: tasks
            ..add(
              DayActivity(
                eventId: eventId,
                taskId: taskId,
                completedCount: increaseCount,
              ),
            ),
        );
      } else {
        final activity = tasks[dayTasksIndex];
        tasks[dayTasksIndex] = activity.copyWith(
          completedCount: activity.completedCount + increaseCount,
        );
        // просто увеличиваем количество завершений
        activities[date] = dayActivity.copyWith(tasks: tasks);
      }
    }

    await saveActivities(activities);
  }

  /// Найти и уменьшить или удалить активность для [eventId]+[taskId] на день [date], уменьшив её количество
  /// на [decreaseCount].
  Future<void> decreaseDayActivity({
    required String eventId,
    required String taskId,
    required DateTime date,
    int decreaseCount = 1,
  }) async {
    final activities = calendarActivities;
    date = getPureDate(date);
    final dayActivity = activities[date];

    // нет активности на эту дату, игнорировать
    if (dayActivity == null) {
      return;
    } else {
      final tasks = List<DayActivity>.from(dayActivity.tasks);
      final dayTasksIndex = tasks.indexWhere(
        (t) => t.eventId == eventId && t.taskId == taskId,
      );

      // нет активности по этому событию в этот день, игнорировать
      if (dayTasksIndex == -1) {
        return;
      } else {
        final activity = tasks[dayTasksIndex];

        if (activity.completedCount - decreaseCount >= 1) {
          tasks[dayTasksIndex] = activity.copyWith(
            completedCount: activity.completedCount - decreaseCount,
          );
        } else {
          tasks.removeAt(dayTasksIndex);
        }

        if (tasks.isEmpty) {
        // удаляем день, если там нет действий
          activities.remove(date);
        } else {
          /// просто уменьшить количество выполнений или удалить, если больше нет действий
          activities[date] = dayActivity.copyWith(tasks: tasks);
        }
      }
    }

    await saveActivities(activities);
  }

  /// Сохранить активности в хранилище и обновить поток новыми данными.
  Future<void> saveActivities(
    Map<DateTime, CalendarDayActivities> activities,
  ) async {
    await shared.setString(
      _calendarActivitiesKey,
      jsonEncode(activities.values.map((e) => e.toJson()).toList()),
    );
    _calendarActivitiesSubject.add(activities);
  }

  /// Получить дату без времени.
  DateTime getPureDate(DateTime date) => DateTime(date.year, date.month, date.day);
}
