import 'dart:ui';

import 'package:events_tracker/data/data.dart';

/// Запланированное событие, которое будет отображать информацию о событии и требуемые действия для
/// его выполнения.
/// Это событие — просто описание общих планов. Для уточнения задач внутри этого плана см. 
/// [EventTaskWithStatistic].
///
/// Эта модель отличается от [EventModel], так как она содержит статистику по выполнению.
class EventModelWithStatistic {
  const EventModelWithStatistic({
    required this.id,
    required this.eventTitle,
    required this.tasks,
    required this.color,
  });

  final String id;
  final String eventTitle;

  /// Список задач, которые необходимо выполнить для завершения мероприятия в целом
  final List<EventTaskWithStatistic> tasks;

  /// Цвет — шестнадцатеричное 32-битное целое число, например 0xFFAABBCC
  final Color color;

  int get completedGeneralPercent =>
      tasks.fold(0, (v, e) => v + e.completedGeneralPercent) ~/ tasks.length.toDouble();
}

/// Одна задача из [EventModelWithStatistic], которая позволяет уточнять разные типы
/// задач внутри какого-то плана.
/// В то время как [EventModelWithStatistic] — это общий план, например, `Бокс`,
/// [EventTaskWithStatistic] — это подзадача для `Бокса`, например:
/// `Посетить 50 тренировок` или `Сделать 10000 отжиманий`
///
/// Эта модель отличается от [EventTask], так как она содержит статистику по выполнению.
class EventTaskWithStatistic {
  const EventTaskWithStatistic({
    required this.id,
    required this.taskName,
    required this.plan,
    required this.completedGeneral,
    required this.completionsByDays,
  });

  final String id;
  final String taskName;

  /// Сколько раз пользователь должен выполнить эту задачу для вашего плана
  final int plan;

  /// Сумма между всеми действиями, указанными для события, будет установлена ​​после всех вычислений.
  /// 0, если нет активности
  final int completedGeneral;

  /// Все дни, когда это задание было выполнено.
  /// Пусто, если нет активности
  final Map<DateTime, CalendarDayTaskStatistics> completionsByDays;

  int get completedGeneralPercent => (completedGeneral / plan.toDouble() * 100).toInt();
}
