import 'package:events_tracker/app/router/router.dart';
import 'package:events_tracker/feature/calendar/calendar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

part 'calendar.g.dart';

@TypedGoRoute<CalendarRoute>(
  path: '/calendar',
  routes: [
    TypedGoRoute<SettingsRoute>(
      path: 'settings',
      routes: [
        TypedGoRoute<AddEventRoute>(
          path: 'addEvent',
        ),
        TypedGoRoute<EditEventRoute>(
          path: 'editEvent/:eventId',
        ),
      ],
    ),
  ],
)
class CalendarRoute extends GoRouteData {
  @override
  Widget build(BuildContext context, GoRouterState state) => const CalendarPage();
}
