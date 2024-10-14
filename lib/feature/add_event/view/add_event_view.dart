import 'package:events_tracker/data/data.dart';
import 'package:events_tracker/feature/add_event/add_event.dart';
import 'package:events_tracker/feature/widgets/widgets.dart';
import 'package:events_tracker/generated/generated.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddEventView extends StatefulWidget {
  const AddEventView({
    required this.state,
    required this.isUpdate,
    super.key,
  });

  final AddEventState state;
  final bool isUpdate;

  @override
  State<AddEventView> createState() => _AddEventViewState();
}

class _AddEventViewState extends State<AddEventView> {
  final _eventNameController = TextEditingController();

  @override
  void initState() {
    if (widget.state.eventName.isNotEmpty) {
      _eventNameController.text = widget.state.eventName;
    }

    super.initState();
  }

  @override
  void dispose() {
    _eventNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canBeCreated = widget.state.canBeCreated;

    return Stack(
      children: [
        AnimatedPositioned(
          duration: kThemeAnimationDuration,
          top: 0,
          left: 16,
          right: 16,
          bottom: !canBeCreated ? 16 : kButtonHeight + 16,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InputWidget(
                  controller: _eventNameController,
                  title: LocaleKeys.eventNameTitle.tr(),
                  hintText: LocaleKeys.eventNameHint.tr(),
                  onChanged: (name) =>
                      context.read<AddEventBloc>().add(AddEventEvent.renameEvent(name: name)),
                ),
                const SizedBox(height: 20),
                ColorPickerWidget(
                  color: widget.state.eventColor,
                  onSelected: (color) => context.read<AddEventBloc>().add(
                        AddEventEvent.changeColor(color: color),
                      ),
                ),
                const SizedBox(height: 20),
               
                ...widget.state.tasks
                    .map<Widget>(
                      (t) => AddEventTaskWidget(task: t, key: Key(t.id)),
                    )
                    .separated(const SizedBox(height: 16)),
                PrimaryTextButton(
                  onPressed: () => context.read<AddEventBloc>().add(
                        const AddEventEvent.addNewTask(),
                      ),
                  text: LocaleKeys.addNewTask.tr(),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: AnimatedCollapse(
            show: canBeCreated,
            child: PrimaryButton(
              onPressed: widget.state.isLoading
                  ? null
                  : () => context.read<AddEventBloc>().add(const AddEventEvent.createEvent()),
              text: widget.isUpdate ? LocaleKeys.updateWord.tr() : LocaleKeys.createWord.tr(),
            ),
          ),
        ),
      ],
    );
  }
}
