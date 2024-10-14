import 'dart:ui';

/// Статистика за один день, содержащая всю информацию о связях событие-задача
class CalendarDayStatistics {
  CalendarDayStatistics({
    required this.date,
    required this.tasksByEvent,
    required this.allTasks,
  });

  final DateTime date;

  /// Ключ - event id, значение - список задач для этого мероприятия в этот день
  final Map<String, List<CalendarDayTaskStatistics>> tasksByEvent;

  /// Список всех задач для всех событий в этот день
  final List<CalendarDayTaskStatistics> allTasks;
}

/// Статистика по задаче за один день и частично за все дни
class CalendarDayTaskStatistics {
  CalendarDayTaskStatistics({
    required this.taskId,
    required this.taskName,
    required this.completedInDay,
    required this.plan,
    required this.eventColor,
    required this.eventId,
    required this.eventTitle,
  });

  final String eventId;
  final String eventTitle;
  final Color eventColor;

  final String taskId;
  final String taskName;

  /// подсчет выполненных задач за какой-то день
  final int completedInDay;

  /// сумма между всеми действиями, указанными для события, будет установлена ​​после всех вычислений
  int completedGeneral = 0;

  final int plan;

  int get completedForDayPercent => (completedInDay / plan.toDouble() * 100).toInt();

  int get completedGeneralPercent => (completedGeneral / plan.toDouble() * 100).toInt();
}
