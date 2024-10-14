import 'dart:async';

import 'package:events_tracker/app/services/localization/localization.dart';
import 'package:injectable/injectable.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';

/// Сервис, предоставляющий функциональность локализации для приложения.
/// Придерживайтесь принципа "делай просто",
/// используйте только в качестве источников потоков для блоков и кубитов,
/// которые выполняют основную работу.

@singleton
class LocalizationService {
  final _log = Logger('LocalizationService');

  final StreamController<void> _refreshLocaleStreamController = StreamController<void>.broadcast();

  final StreamController<SupportedLocaleCodes> _updateLocaleStreamController =
      StreamController<SupportedLocaleCodes>.broadcast();

  /// Это поток-инициатор, который позволяет обновлять локали с помощью [LocalizationServiceWidget],
  /// используется только внутри [LocalizationServiceWidget].
  Stream<void> get refreshLocaleStream => _refreshLocaleStreamController.stream;

  /// Это поток-инициатор, который позволяет обновлять локали с использованием
  /// [LocalizationServiceWidget], используется только внутри
  /// [LocalizationServiceWidget].
  Stream<SupportedLocaleCodes> get updateLocaleStream => _updateLocaleStreamController.stream;

  /// Выполняет обновление локали (например, при изменении системной локали).
  void refreshLocale() {
    _log.finest('refreshing locales');
    _refreshLocaleStreamController.add(null);
  }

  final _localeCodeStreamController = BehaviorSubject<SupportedLocaleCodes>();

  /// Это просто "обратный вызов" от [LocalizationServiceWidget],
  /// который позволяет обновлять код локали через виджет,
  ///  используется только внутри [LocalizationServiceWidget].

  void updateCurrentLocaleByLanguageCodeFromServiceWidget(
    SupportedLocaleCodes code,
  ) {
    if (_localeCodeStreamController.valueOrNull == code) return;

    _log.finest('setting locale by code "${code.name}"');

    _localeCodeStreamController.add(code);
  }

  /// Публичный сеттер для кода локали.
  void changeLocaleCode(SupportedLocaleCodes code) {
    if (_localeCodeStreamController.valueOrNull == code) return;

    _log.finest('changing locale code to "${code.name}"');

    _updateLocaleStreamController.add(code);
  }

  /// Публичный геттер для кода локали.
  SupportedLocaleCodes get localeCode =>
      _localeCodeStreamController.valueOrNull ?? fallbackLocaleCode;

  /// Публичный поток кода локали.
  ValueStream<SupportedLocaleCodes> get localeCodeStream => _localeCodeStreamController.stream;
}
