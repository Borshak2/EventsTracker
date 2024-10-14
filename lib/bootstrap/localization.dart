import 'package:easy_logger/easy_logger.dart';
import 'package:events_tracker/generated/generated.dart';
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';

/// Это метод, который позволяет настроить некоторые функции, связанные с сервисами.
Future<void> configureLocalization() async {
  final bootstrapLog = Logger('bootstrap')..finest('EasyLocalization initializating...');
  final easyLocalizationLog = Logger('easyLocalization');

  WidgetsFlutterBinding.ensureInitialized();

  void customLogPrinter(
    Object object, {
    LevelMessages? level,
    // ignore: avoid-unused-parameters
    String? name,
    StackTrace? stackTrace,
  }) {
    final logLevel = switch (level) {
      LevelMessages.error => Level.SEVERE,
      LevelMessages.warning => Level.WARNING,
      LevelMessages.info => Level.INFO,
      LevelMessages.debug => Level.FINE,
      null => Level.FINE,
    };
    easyLocalizationLog.log(logLevel, object, null, stackTrace);
  }

  EasyLocalization.logger.printer = customLogPrinter;
  await EasyLocalization.ensureInitialized();

  bootstrapLog.finest('EasyLocalization initialized');
}
