import 'package:events_tracker/app/router/router.dart';
import 'package:events_tracker/data/data.dart';
import 'package:events_tracker/feature/settings/settings.dart';
import 'package:events_tracker/feature/widgets/widgets.dart';
import 'package:events_tracker/generated/generated.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

/// Виджет, позволяющий отображать событие и его задачи в выпадающем списке
class EventAndTasksSettingsWidget extends StatefulWidget {
  const EventAndTasksSettingsWidget({
    required this.event,
    super.key,
  });

  final EventModelWithStatistic event;

  @override
  State<EventAndTasksSettingsWidget> createState() => _EventAndTasksSettingsWidgetState();
}

class _EventAndTasksSettingsWidgetState extends State<EventAndTasksSettingsWidget> {
  final _controller = ExpandableController(initialExpanded: false);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Material(
        borderRadius: BorderRadius.circular(8),
        color: widget.event.color.eventBackgroundColor,
        child: ExpandablePanel(
          controller: _controller,
          header: _eventBody(context),  
          theme: const ExpandableThemeData(
            hasIcon: false,
            tapHeaderToExpand: false,
            tapBodyToCollapse: false,
          ),
          collapsed: const SizedBox.shrink(),
          expanded: _tasksList(),
        ),
      ),
    );
  }

  Widget _eventBody(BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.3,
        children: [
          SlidableAction(
            padding: EdgeInsets.zero,
            icon: Icons.edit,
            backgroundColor: Colors.blue[500]!,
            borderRadius: BorderRadius.circular(12),
            onPressed: (context) => EditEventRoute(widget.event.id).go(context),
          ),
          const SizedBox(width: 2),
          SlidableAction(
            padding: EdgeInsets.zero,
            icon: Icons.delete,
            backgroundColor: Colors.red[400]!,
            borderRadius: BorderRadius.circular(12),
            onPressed: (_) async {
              final result = await showConfirmRemoveEventSheet(context, widget.event);

              if (result && context.mounted) {
                context.read<SettingsBloc>().add(SettingsEvent.removeEvent(widget.event.id));
              }
            },
          ),
        ],
      ),
      child: _eventContent(),
    );
  }

  Widget _eventContent() {
    return ListTile(
      horizontalTitleGap: 8,
      leading: EventColorWidget.medium(color: widget.event.color),
      title: Text(
        widget.event.eventTitle,
      ),
      subtitle: Text(
        LocaleKeys.eventCompletedCountAndPercent.tr(
          args: [widget.event.completedGeneralPercent.toString()],
        ),
      ),
      trailing: ValueListenableBuilder<bool>(
        valueListenable: _controller,
        builder: (context, isExpanded, _) {
          return AnimatedRotation(
            duration: kThemeAnimationDuration,
            turns: isExpanded ? 0.25 : 0,
            child: IconButton(
              onPressed: () => _controller.toggle(),
              icon: const Icon(Icons.chevron_right_rounded),
            ),
          );
        },
      ),
    );
  }

  Widget _tasksList() {
    return Padding(
      padding: const EdgeInsets.only(left: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widget.event.tasks.map(_taskItem).toList(),
      ),
    );
  }

  Widget _taskItem(EventTaskWithStatistic task) {
    return ListTile(
      title: Text(task.taskName),
      subtitle: Text(
        LocaleKeys.taskCompletedCountAndPercent.tr(
          args: [
            task.completedGeneral.toString(),
            task.plan.toString(),
            task.completedGeneralPercent.toString(),
          ],
        ),
      ),
    );
  }
}
