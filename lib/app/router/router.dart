import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'routes/routes.dart';
export 'routes/routes.dart';

final routerKey = GlobalKey<NavigatorState>();

GoRouter getRouter(BuildContext _) {
  // Создание нового маршрута
  final router = GoRouter(
    restorationScopeId: 'app',
    navigatorKey: routerKey,
    initialLocation: CalendarRoute().location,
    routes: $appRoutes,
  );

  return router;
}
