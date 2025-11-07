import 'package:camera_picker/camera_picker.dart';
import 'package:flutter/material.dart';

class BarcodeScannerPage extends StatelessWidget {
  const BarcodeScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    String? barcodeValue;
    return StatefulBuilder(
      builder: (context, setState) => Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          spacing: 16.0,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (barcodeValue != null) Expanded(child: Text("$barcodeValue")),
            FilledButton.icon(
              onPressed: () async {
                barcodeValue = await CameraPicker.scanBarcode(context);
                setState(() {});
              },
              label: Text("Scan Barcode"),
            ),
          ],
        ),
      ),
    );
  }
}
