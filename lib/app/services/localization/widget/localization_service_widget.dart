import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:events_tracker/app/services/localization/localization.dart';
import 'package:events_tracker/di/di.dart';
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';

/// LocalizationServiceWidget — это виджет, который позволяет слушать события из [LocalizationService]
/// и реагировать на них, отправляя обновления локали (что доступно только через контекст).
/// Да, здесь не используются cubit или bloc, потому что не требуется управление состоянием, нужно
/// просто слушать события и немедленно на них реагировать.

class LocalizationServiceWidget extends StatefulWidget {
  const LocalizationServiceWidget({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  State<LocalizationServiceWidget> createState() => _LocalizationServiceWidgetState();
}

class _LocalizationServiceWidgetState extends State<LocalizationServiceWidget> {
  final _log = Logger('LocalizationServiceWidget');
  StreamSubscription<void>? _refreshLocaleSubscription;
  StreamSubscription<void>? _updateLocaleSubscription;

  @override
  void initState() {
    super.initState();

    _refreshLocaleSubscription = inject<LocalizationService>().refreshLocaleStream.listen(
          (_) => _setLocaleByLanguageCode(),
        );

    _updateLocaleSubscription = inject<LocalizationService>().updateLocaleStream.listen(
          _updateLocaleByLanguageCode,
        );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setLocaleByLanguageCode();
    });
  }

  void _setLocaleByLanguageCode() {
    final languageCode = context.locale.languageCode;

    _log.finest('set locale by language code $languageCode');

    inject<LocalizationService>().updateCurrentLocaleByLanguageCodeFromServiceWidget(
      SupportedLocaleCodes.byName(languageCode),
    );
  }

  void _updateLocaleByLanguageCode(SupportedLocaleCodes code) {
    _log.finest('update locale by language code ${code.name}');

    context.setLocale(code.locale);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setLocaleByLanguageCode();
    });
  }

  @override
  void dispose() {
    _refreshLocaleSubscription?.cancel();
    _updateLocaleSubscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
