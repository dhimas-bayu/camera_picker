import 'package:flutter/material.dart';

class PermissionView extends StatelessWidget {
  const PermissionView({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox.fromSize(
          size: constraints.biggest,
          child: const Column(
            spacing: 4.0,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.cancel_outlined, size: 64.0, color: Colors.white),
              Text(
                "Camera permission required, Please enabled it in settings.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.0, color: Colors.white),
              ),
            ],
          ),
        );
      }
    );
  }
}
