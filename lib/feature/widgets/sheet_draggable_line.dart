import 'package:flutter/material.dart';

/// Draggable line that displays in top of a sheet to let user know that
/// he can drag sheet.
class SheetDraggableLine extends StatelessWidget {
  const SheetDraggableLine({
    required this.height,
    required this.verticalMargin,
    super.key,
  });

  final double height;
  final double verticalMargin;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: height,
        width: 40,
        margin: EdgeInsets.symmetric(vertical: verticalMargin),
        decoration: ShapeDecoration(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(24),
            ),
          ),
          color: Colors.grey[600],
        ),
      ),
    );
  }
}
