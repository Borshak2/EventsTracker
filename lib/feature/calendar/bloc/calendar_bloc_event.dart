part of 'calendar_bloc.dart';

@freezed
class CalendarBlocEvent with _$CalendarBlocEvent {
  const factory CalendarBlocEvent.updateActivities(
    Map<DateTime, CalendarDayStatistics> activities,
  ) = _UpdateActivities;
}
