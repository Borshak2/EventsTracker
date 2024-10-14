import 'package:events_tracker/app/router/router.dart';
import 'package:events_tracker/di/di.dart';
import 'package:events_tracker/feature/settings/settings.dart';
import 'package:events_tracker/generated/generated.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Страница, позволяющая просмотреть список событий и перейти к его добавлению или обновлению
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SettingsBloc>(
      create: (_) => SettingsBloc(inject()),
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text(LocaleKeys.eventsSettingsTitle.tr()),
            ),
            body: SettingsView(events: state.events),
            floatingActionButton: state.events.isEmpty
                ? null
                : FloatingActionButton(
                    onPressed: () => AddEventRoute().go(context),
                    child: const Icon(Icons.add),
                  ),
          );
        },
      ),
    );
  }
}
