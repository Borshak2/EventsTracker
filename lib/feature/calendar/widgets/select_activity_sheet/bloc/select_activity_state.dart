part of 'select_activity_bloc.dart';

@freezed
class SelectActivityState with _$SelectActivityState {
  const factory SelectActivityState.loading() = _Loading;

  const factory SelectActivityState.data({
    required List<EventModel> events,
    required bool created,
    EventModel? selectedEvent,
    EventTask? selectedTask,
    int? selectedAmount,
  }) = _Data;
}
