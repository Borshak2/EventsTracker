part of 'calendar_bloc.dart';

@freezed
class CalendarBlocState with _$CalendarBlocState {
  const factory CalendarBlocState({
    required Map<DateTime, CalendarDayStatistics> activities,
  }) = _State;
}
