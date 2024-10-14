import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:events_tracker/data/data.dart';

part 'calendar_day_activities.freezed.dart';
part 'calendar_day_activities.g.dart';

/// Действия, выполненные за один день для разных событий.
/// В течение одного дня пользователь может выполнить разные события и с разным количеством
/// выполнений.
/// Например, за один день пользователь может выполнить 100 отжиманий, когда план составляет 10000.
@freezed
class CalendarDayActivities with _$CalendarDayActivities {
  const factory CalendarDayActivities({
    @dateTimeJsonConverter required DateTime date,
    required List<DayActivity> tasks,
  }) = _CalendarDayActivities;

  factory CalendarDayActivities.fromJson(Map<String, dynamic> json) =>
      _$CalendarDayActivitiesFromJson(json);
}

extension CalendarDayExt on CalendarDayActivities {
  Map<String, DayActivity> getEventActivity(String eventId) => Map.fromEntries(
        tasks.where((t) => t.eventId == eventId).map((e) => MapEntry(e.taskId, e)),
      );
}

/// Сколько раз какая-то задача из события была выполнена в течение дня.
@freezed
class DayActivity with _$DayActivity {
  const factory DayActivity({
    required String eventId,
    required String taskId,
    // счетчик не может быть меньше 1. Если да, то активность следует удалить
    required int completedCount,
  }) = _DayActivity;

  factory DayActivity.fromJson(Map<String, dynamic> json) => _$DayActivityFromJson(json);
}
