part of 'add_event_bloc.dart';

@freezed
class AddEventEvent with _$AddEventEvent {
  const factory AddEventEvent.createEvent() = _CreateEvent;

  const factory AddEventEvent.renameEvent({
    required String name,
  }) = _RenameEvent;

  const factory AddEventEvent.changeColor({
    required Color color,
  }) = _ChangeColor;

  const factory AddEventEvent.addNewTask() = _AddNewTask;

  const factory AddEventEvent.renameTask({
    required String id,
    required String name,
  }) = _RenameTask;

  const factory AddEventEvent.changeTaskPlan({
    required String id,
    required int plan,
  }) = _ChangeTaskPlan;

  const factory AddEventEvent.removeTask({
    required String id,
  }) = _RemoveTask;
}
