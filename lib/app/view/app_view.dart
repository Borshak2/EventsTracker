import 'package:easy_localization/easy_localization.dart';
import 'package:events_tracker/app/router/router.dart';
import 'package:events_tracker/app/view/view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppView extends StatefulWidget {
  const AppView({super.key});

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  late GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = getRouter(context);
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: createTheme(
        brightness: Brightness.light,
        primaryTextColor: Colors.black,
        secondaryTextColor: Colors.grey,
      ),
      darkTheme: createTheme(
        brightness: Brightness.dark,
        primaryTextColor: Colors.white,
        secondaryTextColor: Colors.grey[350]!,
      ),
      builder: (context, child) => AppRootWidgets(child: child ?? Container()),
    );
  }
}

ThemeData createTheme({
  required Brightness brightness,
  required Color primaryTextColor,
  required Color secondaryTextColor,
}) {
  final styles = const TextTheme(
    titleLarge: TextStyle(fontSize: 18),
    titleMedium: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w500,
    ),
    titleSmall: TextStyle(
      fontSize: 10,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
    bodyMedium: TextStyle(fontSize: 14),
    bodySmall: TextStyle(fontSize: 12),
  ).apply(
    bodyColor: primaryTextColor,
    decorationColor: secondaryTextColor,
    displayColor: secondaryTextColor,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue[900]!,
      brightness: brightness,
    ),
    listTileTheme: ListTileThemeData(
      textColor: null,
      titleTextStyle: styles.titleMedium,
      subtitleTextStyle: styles.bodySmall,
    ),
    textTheme: styles,
  );
}
