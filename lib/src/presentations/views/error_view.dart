import 'package:flutter/material.dart';

class ErrorCameraView extends StatelessWidget {
  const ErrorCameraView({super.key, required this.errorMessage});
  final String errorMessage;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          height: constraints.biggest.height,
          width: constraints.biggest.width,
          color: Colors.black,
          padding: const EdgeInsets.all(24.0),
          child: Column(
            spacing: 8.0,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.camera_alt_outlined,
                size: 56.0,
                color: Colors.white,
              ),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
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
