part of 'add_event_bloc.dart';

@freezed
class AddEventState with _$AddEventState {
  const factory AddEventState({
    required String eventName,
    required Color eventColor,
    required List<EventTask> tasks,
    required bool created,
    required bool isLoading,
  }) = _State;
}

extension AddEventStateX on AddEventState {
  bool get isEmpty =>
      eventName.isEmpty || tasks.isEmpty || tasks.any((t) => t.taskName.isEmpty || t.plan == 0);

  bool get canBeCreated => !isEmpty;
}
