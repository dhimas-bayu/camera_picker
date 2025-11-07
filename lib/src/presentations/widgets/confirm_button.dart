import 'package:flutter/material.dart';

enum ConfirmAction { accept, reject }

class ConfirmButton extends StatelessWidget {
  const ConfirmButton({super.key, required this.action, this.onAction});
  final ConfirmAction action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      style: IconButton.styleFrom(
        backgroundColor: Colors.white38,
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white),
        fixedSize: const Size.square(48.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      onPressed: onAction,
      icon: switch (action) {
        ConfirmAction.reject => const Icon(Icons.close_rounded),
        ConfirmAction.accept => const Icon(Icons.check_rounded),
      },
    );
  }
}
