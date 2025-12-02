import 'package:flutter/material.dart';

class PermissionView extends StatelessWidget {
  const PermissionView({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          height: constraints.biggest.height,
          width: constraints.biggest.width,
          color: Colors.black,
          padding: const EdgeInsets.all(24.0),
          child: const Column(
            spacing: 8.0,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.perm_camera_mic_rounded,
                size: 56.0,
                color: Colors.white,
              ),
              Text(
                "Camera permission required, Please allow camera permissions.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
