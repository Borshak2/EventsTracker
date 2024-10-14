import 'dart:math';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:events_tracker/app/services/services.dart';
import 'package:events_tracker/data/data.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'add_event_state.dart';
part 'add_event_event.dart';
part 'add_event_bloc.freezed.dart';

class AddEventBloc extends Bloc<AddEventEvent, AddEventState> {
  AddEventBloc(this.service, this.oldEvent)
      : super(
          oldEvent == null
              ? AddEventState(
                  eventName: '',
                  // генерируем случайный цвет от 35 до 225 (без углов)
                  eventColor: Color.fromARGB(
                    255,
                    Random().nextInt(190) + 35,
                    Random().nextInt(190) + 35,
                    Random().nextInt(190) + 35,
                  ),
                  tasks: [],
                  created: false,
                  isLoading: false,
                )
              : AddEventState(
                  eventName: oldEvent.eventTitle,
                  // генерируем случайный цвет от 35 до 225 (без углов)
                  eventColor: oldEvent.color,
                  tasks: oldEvent.tasks,
                  created: false,
                  isLoading: false,
                ),
        ) {
    _registerHandlers();
  }

  EventModel? oldEvent;
  final CalendarService service;

  void _registerHandlers() {
    on<_CreateEvent>(
      (_, emit) async {
        emit(state.copyWith(isLoading: true));

        if (oldEvent != null) {
          await service.updateEvent(
            eventId: oldEvent!.id,
            eventName: state.eventName,
            color: state.eventColor,
            tasks: state.tasks,
          );
        } else {
          await service.createEvent(
            eventName: state.eventName,
            color: state.eventColor,
            tasks: state.tasks,
          );
        }

        emit(state.copyWith(isLoading: false, created: true));
      },
    );

    on<_RenameEvent>(
      (event, emit) => emit(state.copyWith(eventName: event.name)),
    );
    on<_ChangeColor>(
      (event, emit) => emit(state.copyWith(eventColor: event.color)),
    );
    on<_AddNewTask>(
      (_, emit) => emit(
        state.copyWith(
          tasks: List.from([...state.tasks, EventTask.create(taskName: '', plan: 0)]),
        ),
      ),
    );
    on<_RenameTask>(
      (event, emit) => emit(
        state.copyWith(
          tasks: state.tasks
              .map((t) => t.id == event.id ? t.copyWith(taskName: event.name) : t)
              .toList(),
        ),
      ),
    );
    on<_ChangeTaskPlan>(
      (event, emit) => emit(
        state.copyWith(
          tasks:
              state.tasks.map((t) => t.id == event.id ? t.copyWith(plan: event.plan) : t).toList(),
        ),
      ),
    );
    on<_RemoveTask>(
      (event, emit) => emit(
        state.copyWith(tasks: state.tasks.where((t) => t.id != event.id).toList()),
      ),
    );
  }
}
