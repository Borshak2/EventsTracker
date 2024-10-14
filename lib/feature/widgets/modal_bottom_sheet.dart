import 'package:events_tracker/feature/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

/// Builder для параметра тела [showCommonBottomSheet].
/// Это позволяет получить [ScrollController] модального листа и использовать его в поле прокрутки.
typedef CommonSheetBodyBuilder = Widget Function(
  BuildContext context,
  ScrollController scrollController,
);

/// Отображение нижнего листа по умолчанию из [context].
///
/// [title] — текст описания листа.
/// [subtitle] — это текст листа, который отображается под [subtitle].
/// [padding] вокруг [body].
/// [avoidBottomInsets] если открытая клавиатура должна изменить размер листа, то же самое
/// как [Scaffold.resizeToAvoidBottomInset].
/// [openFullScreen], если [body] должно отображаться на весь экран.
/// [useAppBackgroundColor] если true, то используется [ColorsPalette.appBackground]
/// как цвет листа, в противном случае — [ColorsPalette.backgroundSecondary].
// ignore: long-method
Future<T?> showCommonBottomSheet<T>({
  required BuildContext context,
  required CommonSheetBodyBuilder body,
  String? title,
  Widget? titleAction,
  String? subtitle,
  EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 16),
  bool expand = false,
  bool dismissible = true,
  bool wrapIntoAnimatedSize = true,
  bool avoidBottomInsets = true,
  bool openFullScreen = false,
  bool useRootNavigator = true,
  Color? barrierColor,
  bool useAppBackgroundColor = false,
  bool centerTitle = false,
}) {
  return showCustomModalBottomSheet<T>(
    expand: expand,
    context: context,
    isDismissible: dismissible,
    useRootNavigator: useRootNavigator,
    barrierColor: barrierColor ?? Colors.black.withOpacity(0.73),
    containerWidget: (context, animation, child) => _ContainerWidget(
      animated: wrapIntoAnimatedSize,
      child: child,
    ),
    builder: (_) => CommonBottomSheetWidget(
      useAppBackgroundColor: useAppBackgroundColor,
      openFullScreen: openFullScreen,
      avoidBottomInsets: avoidBottomInsets,
      padding: padding,
      subtitle: subtitle,
      title: title,
      titleAction: titleAction,
      centerTitle: centerTitle,
      body: body,
    ),
  );
}

/// Возвращаем маршрут нижнего листа, который можно использовать напрямую в навигаторе.
/// Этот маршрут может быть полезен как `Navigator.of(context)..pop()..push()`
///
/// [title] — текст описания листа.
/// [subtitle] — это текст листа, который отображается под [заголовком].
/// [padding] вокруг [body].
/// [avoidBottomInsets] если открытая клавиатура должна изменить размер листа, то же самое
/// как [Scaffold.resizeToAvoidBottomInset].
/// [openFullScreen], если [body] должно отображаться на весь экран.
/// [useAppBackgroundColor] если true, то используется [ColorsPalette.appBackground]
/// как цвет листа, в противном случае — [ColorsPalette.backgroundSecondary].
// ignore: long-method
ModalSheetRoute<T> commonBottomSheetRoute<T>({
  required CommonSheetBodyBuilder body,
  String? title,
  Widget? titleAction,
  String? subtitle,
  EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 16),
  bool expand = false,
  bool dismissible = true,
  bool wrapIntoAnimatedSize = true,
  bool avoidBottomInsets = true,
  bool openFullScreen = false,
  Color? barrierColor,
  bool useAppBackgroundColor = false,
  bool centerTitle = false,
}) {
  return ModalSheetRoute<T>(
    builder: (_) => CommonBottomSheetWidget(
      useAppBackgroundColor: useAppBackgroundColor,
      openFullScreen: openFullScreen,
      avoidBottomInsets: avoidBottomInsets,
      padding: padding,
      subtitle: subtitle,
      title: title,
      titleAction: titleAction,
      body: body,
      centerTitle: centerTitle,
    ),
    expanded: expand,
    isDismissible: dismissible,
    modalBarrierColor: barrierColor,
    containerBuilder: (context, animation, child) => _ContainerWidget(
      animated: wrapIntoAnimatedSize,
      child: child,
    ),
  );
}

/// Виджет, отображающий содержимое bottom sheet по умолчанию.
class CommonBottomSheetWidget extends StatelessWidget {
  const CommonBottomSheetWidget({
    required this.body,
    required this.padding,
    required this.avoidBottomInsets,
    required this.openFullScreen,
    required this.useAppBackgroundColor,
    required this.centerTitle,
    this.title,
    this.titleAction,
    this.subtitle,
    super.key,
  });

  final CommonSheetBodyBuilder body;
  final Widget? titleAction;
  final String? title;
  final String? subtitle;
  final EdgeInsets padding;
  final bool avoidBottomInsets;
  final bool openFullScreen;
  final bool useAppBackgroundColor;
  final bool centerTitle;

  @override
  Widget build(BuildContext context) {
    const dragWidgetSize = 4.0;
    const dragWidgetMargin = 8.0;
    final textTheme = Theme.of(context).textTheme;
    Widget? titleWidget = title == null
        ? null
        : Container(
            margin: const EdgeInsets.symmetric(horizontal: 16) +
                EdgeInsets.only(
                  top: 20 + dragWidgetSize + dragWidgetMargin * 2,
                  bottom: subtitle != null ? 12 : 24,
                ),
            child: Align(
              alignment: centerTitle ? Alignment.center : Alignment.centerLeft,
              child: Text(
                title!,
                style: textTheme.titleLarge,
                textAlign: centerTitle ? TextAlign.center : TextAlign.start,
              ),
            ),
          );
    if (titleAction != null) {
      titleWidget = Row(
        children: [
          Expanded(
            child: titleWidget ?? const SizedBox.shrink(),
          ),
          const SizedBox(width: 8),
          titleAction!,
        ],
      );
    }

    final bodyWidget = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (titleWidget != null) titleWidget,
        if (subtitle != null)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16) +
                EdgeInsets.only(
                  bottom: 24,
                  top: title == null ? 20 + dragWidgetSize + dragWidgetMargin * 2 : 0,
                ),
            child: Text(
              subtitle!,
              style: textTheme.bodySmall,
            ),
          ),
        Flexible(
          child: Padding(
            padding: padding,
            child: body(
              context,
              ModalScrollController.of(context)!,
            ),
          ),
        ),
      ],
    );

    return Material(
      child: SafeArea(
        minimum: avoidBottomInsets ? const EdgeInsets.only(bottom: 24) : EdgeInsets.zero,
        child: Padding(
          padding: avoidBottomInsets ? MediaQuery.of(context).viewInsets : EdgeInsets.zero,
          child: Stack(
            children: [
              if (openFullScreen) Positioned.fill(child: bodyWidget) else bodyWidget,
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SheetDraggableLine(
                  height: dragWidgetSize,
                  verticalMargin: dragWidgetMargin,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContainerWidget extends StatefulWidget {
  const _ContainerWidget({
    required this.child,
    this.animated = true,
  });

  final Widget child;
  final bool animated;

  @override
  __ContainerWidgetState createState() => __ContainerWidgetState();
}

class __ContainerWidgetState extends State<_ContainerWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 24,
      ),
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      width: double.infinity,
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        removeBottom: true,
        child: widget.animated
            ? AnimatedSize(
                duration: kThemeAnimationDuration,
                reverseDuration: kThemeAnimationDuration,
                curve: Curves.decelerate,
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                child: widget.child,
              )
            : widget.child,
      ),
    );
  }
}
