import 'package:flutter/material.dart';

class FocusIndicator extends StatelessWidget {
  const FocusIndicator({super.key, this.offset});
  final Offset? offset;

  @override
  Widget build(BuildContext context) {
    const indicatorSize = 56.0;

    if (offset != null) {
      return AnimatedPositioned(
        left: offset!.dx - (indicatorSize / 2),
        top: offset!.dy - (indicatorSize / 2),
        duration: Durations.short4,
        child: Container(
          width: indicatorSize,
          height: indicatorSize,
          decoration: const ShapeDecoration(
            shape: CircleBorder(
              side: BorderSide(
                color: Colors.lightGreen,
              ),
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
