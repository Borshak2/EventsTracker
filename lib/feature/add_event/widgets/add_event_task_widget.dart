import 'package:events_tracker/data/data.dart';
import 'package:events_tracker/feature/add_event/add_event.dart';
import 'package:events_tracker/feature/widgets/widgets.dart';
import 'package:events_tracker/generated/generated.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddEventTaskWidget extends StatefulWidget {
  const AddEventTaskWidget({
    required this.task,
    super.key,
  });

  final EventTask task;

  @override
  State<AddEventTaskWidget> createState() => _AddEventTaskWidgetState();
}

class _AddEventTaskWidgetState extends State<AddEventTaskWidget> {
  final _nameFocus = FocusNode();
  final _nameController = TextEditingController();

  final _planFocus = FocusNode();
  final _planController = TextEditingController();

  bool _planLastFocusValue = false;
  bool _nameLastFocusValue = false;

  @override
  void initState() {
    _nameFocus.addListener(() {
      // focus removed when it was
      if (_nameLastFocusValue && !_nameFocus.hasFocus) {
        context
            .read<AddEventBloc>()
            .add(AddEventEvent.renameTask(id: widget.task.id, name: _nameController.text));
      }

      _nameLastFocusValue = _nameFocus.hasFocus;
    });

    _planFocus.addListener(() {
      // focus removed when it was
      if (_planLastFocusValue && !_planFocus.hasFocus) {
        context.read<AddEventBloc>().add(
              AddEventEvent.changeTaskPlan(
                id: widget.task.id,
                plan: int.tryParse(_planController.text) ?? 0,
              ),
            );
      }

      _planLastFocusValue = _planFocus.hasFocus;
    });

    if (widget.task.taskName.isNotEmpty) {
      _nameController.text = widget.task.taskName;
    }

    _updatePlan(widget.task.plan);

    super.initState();
  }

  @override
  void didUpdateWidget(covariant AddEventTaskWidget oldWidget) {
    if (_planController.text != widget.task.plan.toString()) {
      _updatePlan(widget.task.plan);
    }
    super.didUpdateWidget(oldWidget);
  }

  void _updatePlan(int plan) {
    if (plan == 0) {
      _planController.text = '';
    } else {
      _planController.text = plan.toString();
    }
  }

  @override
  void dispose() {
    _nameFocus.dispose();
    _nameController.dispose();

    _planFocus.dispose();
    _planController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InputWidget(
          controller: _nameController,
          focusNode: _nameFocus,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.next,
          title: LocaleKeys.taskNameTitle.tr(),
          hintText: LocaleKeys.taskNameHint.tr(),
          action: PrimaryIconButton(
            onPressed: () =>
                context.read<AddEventBloc>().add(AddEventEvent.removeTask(id: widget.task.id)),
            icon: const Icon(Icons.delete, color: Colors.red),
          ),
        ),
        const SizedBox(height: 4),
        AmountInputWidget(
          focus: _planFocus,
          controller: _planController,
          title: LocaleKeys.planTitle.tr(),
          subtitle: LocaleKeys.planDescription.tr(),
          hintText: LocaleKeys.planHint.tr(),
          increaseCallback: () => context.read<AddEventBloc>().add(
                AddEventEvent.changeTaskPlan(id: widget.task.id, plan: widget.task.plan + 1),
              ),
          decreaseCallback: widget.task.plan <= 0
              ? null
              : () => context.read<AddEventBloc>().add(
                    AddEventEvent.changeTaskPlan(
                      id: widget.task.id,
                      plan: widget.task.plan - 1,
                    ),
                  ),
        ),
      ],
    );
  }
}
