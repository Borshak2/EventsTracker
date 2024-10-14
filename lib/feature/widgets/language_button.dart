import 'package:events_tracker/app/services/services.dart';
import 'package:events_tracker/di/di.dart';
import 'package:events_tracker/generated/generated.dart';
import 'package:flutter/material.dart';

class LanguageButton extends StatefulWidget {
  const LanguageButton({super.key});

  @override
  State<LanguageButton> createState() => _LanguageButtonState();
}

class _LanguageButtonState extends State<LanguageButton> {
  final service = inject<LocalizationService>();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        final currentLocale = context.locale.languageCode;

        final newLocale = currentLocale == SupportedLocaleCodes.ru.name
            ? SupportedLocaleCodes.en
            : SupportedLocaleCodes.ru;

        service.changeLocaleCode(newLocale);
      },
      child: Text(LocaleKeys.changeWord.tr()),
    );
  }
}
