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
            Expanded(
              flex: 2,
              child: Card.filled(
                clipBehavior: Clip.antiAlias,
                child: barcodeValue != null
                    ? Center(child: Text(barcodeValue!))
                    : SizedBox.expand(),
              ),
            ),
            Flexible(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
                childAspectRatio: 1.8,
                children: [
                  MaterialButton(
                    elevation: 0,
                    color: Color(0xff5758a6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    onPressed: () async {
                      barcodeValue = await CameraPicker.scanBarcode(
                        context,
                        config: CameraScannerConfig(autoTracking: false),
                      );
                      setState(() {});
                    },
                    child: Text(
                      "Static Overlay",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  MaterialButton(
                    elevation: 0,
                    color: Color(0xff86b05d),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    onPressed: () async {
                      barcodeValue = await CameraPicker.scanBarcode(
                        context,
                        config: CameraScannerConfig(autoTracking: true),
                      );
                      setState(() {});
                    },
                    child: Text(
                      "Dinamic Overlay",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  MaterialButton(
                    elevation: 0,
                    color: Color(0xffc77974),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    onPressed: () async {
                      barcodeValue = await CameraPicker.scanBarcode(
                        context,
                        config: CameraScannerConfig(
                          autoTracking: false,
                          filterText: RegExp(
                            r'\b(no_ttss|kdtk|kdcab)\b',
                            caseSensitive: false,
                          ),
                        ),
                      );
                      setState(() {});
                    },
                    child: Text(
                      "Static Overlay With Filter Barcode Value",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  MaterialButton(
                    elevation: 0,
                    color: Color(0xff453535),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    onPressed: () async {
                      barcodeValue = await CameraPicker.scanBarcode(
                        context,
                        config: CameraScannerConfig(
                          autoTracking: true,
                          filterText: RegExp(
                            r'\b(no_ttss|kdtk|kdcab)\b',
                            caseSensitive: false,
                          ),
                        ),
                      );
                      setState(() {});
                    },
                    child: Text(
                      "Dynamic Overlay With Filter Barcode Value",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
