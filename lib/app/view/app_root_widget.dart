import 'package:events_tracker/app/services/localization/localization.dart';
import 'package:flutter/widgets.dart';

/// Виджет, который нужно разместить в корне приложения
/// Это хорошее место для размещения сервисов, которые должны быть доступны
/// во всем приложении
class AppRootWidgets extends StatelessWidget {
  const AppRootWidgets({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LocalizationServiceWidget(
      child: child,
    );
  }
}
