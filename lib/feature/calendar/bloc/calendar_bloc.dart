import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:events_tracker/app/services/services.dart';
import 'package:events_tracker/data/data.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'calendar_bloc_event.dart';
part 'calendar_bloc_state.dart';
part 'calendar_bloc.freezed.dart';

class CalendarBloc extends Bloc<CalendarBlocEvent, CalendarBlocState> {
  CalendarBloc({
    required this.calendarService,
  }) : super(const CalendarBlocState(activities: {})) {
    _registerHandlers();

    _activitiesSub = calendarService.mappedEventsActivityStream.listen(
      (acts) => add(CalendarBlocEvent.updateActivities(acts)),
    );
  }

  late StreamSubscription<dynamic> _activitiesSub;

  final CalendarService calendarService;

  void _registerHandlers() {
    on<_UpdateActivities>(
      (event, emit) => emit(state.copyWith(activities: event.activities)),
    );
  }

  @override
  Future<void> close() {
    _activitiesSub.cancel();

    return super.close();
  }
}
