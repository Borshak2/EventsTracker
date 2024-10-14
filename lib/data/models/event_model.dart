import 'dart:ui';

import 'package:events_tracker/data/data.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

part 'event_model.freezed.dart';
part 'event_model.g.dart';

/// Запланированное событие, которое будет отображать информацию о событии и требуемые действия для
/// его выполнения.
/// Это событие — просто описание общих планов. Для уточнения задач внутри этого плана см. 
/// [EventTask].
@freezed
class EventModel with _$EventModel {
  const factory EventModel({
    required String id,
    required String eventTitle,
    // список задач, которые необходимо выполнить для завершения мероприятия в целом
    required List<EventTask> tasks,
    // цвет — шестнадцатеричное 32-битное целое число, например 0xFFAABBCC
    @colorJsonConverter required Color color,
  }) = _EventModel;

  factory EventModel.create({
    required String eventTitle,
    required List<EventTask> tasks,
    required Color color,
  }) =>
      EventModel(
        id: const Uuid().v4(),
        eventTitle: eventTitle,
        tasks: tasks,
        color: color,
      );

  factory EventModel.fromJson(Map<String, dynamic> json) => _$EventModelFromJson(json);
}

/// Одна задача из [EventModel], которая позволяет уточнять разные типы
/// задач внутри какого-то плана.
/// В то время как [EventModel] — это общий план, например, `Бокс`,
/// [EventTask] — это подзадача для `Бокса`, например:
/// `Посетить 50 тренировок` или `Сделать 10000 отжиманий`.
@freezed
class EventTask with _$EventTask {
  const factory EventTask({
    required String id,
    required String taskName,
    // сколько раз пользователь должен выполнить эту задачу для вашего плана
    required int plan,
  }) = _EventTask;

  factory EventTask.create({
    required String taskName,
    required int plan,
  }) =>
      EventTask(
        id: const Uuid().v4(),
        taskName: taskName,
        plan: plan,
      );

  factory EventTask.fromJson(Map<String, dynamic> json) => _$EventTaskFromJson(json);
}
