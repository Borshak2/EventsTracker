import 'package:events_tracker/feature/add_event/add_event.dart';
import 'package:events_tracker/feature/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';



class SettingsRoute extends GoRouteData {
  @override
  Widget build(BuildContext context, GoRouterState state) => const SettingsPage();
}

class AddEventRoute extends GoRouteData {
  @override
  Widget build(BuildContext context, GoRouterState state) => const AddOrEditEventPage();
}

class EditEventRoute extends GoRouteData {
  final String eventId;

  EditEventRoute(this.eventId);

  @override
  Widget build(BuildContext context, GoRouterState state) => AddOrEditEventPage(eventId: eventId);
}
