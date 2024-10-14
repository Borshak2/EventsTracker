import 'dart:async';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:events_tracker/bootstrap/bootstrap.dart';
import 'package:events_tracker/di/di.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

import 'app/services/localization/service/service.dart';

Future<void> bootstrap(
  Widget Function() builder,
) async {
  final log = Logger('bootstrap');

  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      await configureDi();
      await configureLocalization();

      FlutterError.onError = (details) {
        log.severe(details.exceptionAsString(), details, details.stack);
      };

      PlatformDispatcher.instance.onError = (error, stack) {
        log.severe(null, error, stack);

        return true;
      };

      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);

      runApp(
        EasyLocalization(
          startLocale: fallbackLocale,
          supportedLocales: supportedLocales,
          path: 'assets/translations',
          fallbackLocale: fallbackLocale,
          useOnlyLangCode: true,
          child: builder(),
        ),
      );
    },
    (error, stackTrace) => log.severe(error.toString(), error, stackTrace),
  );
}
