# camera_picker

A comprehensive Flutter camera picker package that provides easy-to-use camera functionality for taking pictures and scanning barcodes/QR codes. The package includes document overlay support, automatic cropping, and barcode scanning capabilities using Google ML Kit.

## Features

- 📸 **Take Pictures**: Capture high-quality images with customizable settings
- 📱 **Barcode/QR Code Scanning**: Real-time barcode and QR code detection using Google ML Kit
- 📄 **Document Overlay Support**: Pre-configured overlay templates for various document types (ID cards, passports, photos, etc.)
- 🎯 **Auto Cropping**: Automatic image cropping based on overlay boundaries
- 🔄 **Camera Switching**: Switch between front and back cameras
- 💡 **Flash Control**: Toggle flash mode for better image quality
- 🔍 **Focus & Zoom**: Tap to focus and pinch to zoom functionality
- ⚙️ **Customizable Configuration**: Extensive configuration options for both image capture and barcode scanning

## Installation

Add `camera_picker` to your `pubspec.yaml`:

```yaml
dependencies:
  camera_picker: ^0.0.1
```

Then run:

```bash
flutter pub get
```

### Permissions

#### Android

Add the following permissions to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-feature android:name="android.hardware.camera" />
<uses-feature android:name="android.hardware.camera.autofocus" />
```

#### iOS

Add the following to `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>This app needs access to camera to take photos and scan barcodes</string>
```

## Usage

### Basic Usage

#### Taking a Picture

```dart
import 'package:camera_picker/camera_picker.dart';
import 'package:flutter/material.dart';
import 'dart:io';

// Take a picture with default settings
final imageFile = await CameraPicker.takePicture(context);

if (imageFile != null) {
  // Use the captured image file
  print('Image saved at: ${imageFile.path}');
}
```

#### Scanning a Barcode/QR Code

```dart
// Scan a barcode or QR code
final barcodeResult = await CameraPicker.scanBarcode(context);

if (barcodeResult != null) {
  // Use the scanned barcode value
  print('Barcode value: $barcodeResult');
}
```

### Advanced Usage

#### Custom Configuration for Image Capture

```dart
// Configure image capture with custom settings
final config = CameraConfig(
  quality: 90,              // Image quality (0-100)
  showOverlay: true,        // Show document overlay
  overlayType: OverlayType.ktp,  // Overlay type (e.g., KTP, passport, etc.)
  autoCropping: true,       // Enable automatic cropping
);

final imageFile = await CameraPicker.takePicture(
  context,
  config: config,
);
```

#### Custom Configuration for Barcode Scanning

```dart
// Configure barcode scanning with custom settings
final config = StreamCameraConfig(
  targetFps: 15,              // Target frames per second for processing
  showOverlay: true,          // Show scanning overlay
  autoTracking: true,         // Enable auto-tracking
  enableLogging: true,         // Enable debug logging
);

final barcodeResult = await CameraPicker.scanBarcode(
  context,
  config: config,
);
```

### Complete Example

```dart
import 'dart:io';
import 'package:camera_picker/camera_picker.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? _capturedImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Camera Picker Example')),
      body: Center(
        child: _capturedImage != null
            ? Image.file(_capturedImage!)
            : Text('No image captured'),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () async {
              final imageFile = await CameraPicker.takePicture(context);
              if (imageFile != null) {
                setState(() {
                  _capturedImage = imageFile;
                });
              }
            },
            child: Icon(Icons.camera),
            tooltip: 'Take Picture',
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () async {
              final barcode = await CameraPicker.scanBarcode(context);
              if (barcode != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Scanned: $barcode')),
                );
              }
            },
            child: Icon(Icons.qr_code_scanner),
            tooltip: 'Scan Barcode',
          ),
        ],
      ),
    );
  }
}
```

## API Reference

### CameraPicker

Main class for camera operations.

#### Methods

##### `takePicture`

Opens the camera picker for taking a picture.

```dart
static Future<File?> takePicture(
  BuildContext context, {
  CameraConfig? config,
})
```

**Parameters:**
- `context`: Build context for navigation
- `config`: Optional [CameraConfig] for customizing capture settings

**Returns:**
- `Future<File?>`: The captured image file, or `null` if the user cancelled

**Example:**
```dart
final imageFile = await CameraPicker.takePicture(context);
```

##### `scanBarcode`

Opens the camera picker for scanning barcodes/QR codes.

```dart
static Future<String?> scanBarcode(
  BuildContext context, {
  StreamCameraConfig? config,
})
```

**Parameters:**
- `context`: Build context for navigation
- `config`: Optional [StreamCameraConfig] for customizing scanning settings

**Returns:**
- `Future<String?>`: The scanned barcode value, or `null` if the user cancelled or no barcode was detected

**Example:**
```dart
final barcode = await CameraPicker.scanBarcode(context);
```

### CameraConfig

Configuration class for image capture.

#### Properties

- `quality` (int, default: 80): Image quality from 0 to 100
- `showOverlay` (bool, default: true): Whether to show the document overlay
- `overlayType` (OverlayType?, default: null): Type of overlay to display
- `autoCropping` (bool, default: true): Enable automatic image cropping based on overlay

#### Example

```dart
final config = CameraConfig(
  quality: 90,
  showOverlay: true,
  overlayType: OverlayType.passport,
  autoCropping: true,
);
```

### StreamCameraConfig

Configuration class for barcode scanning.

#### Properties

- `showOverlay` (bool, default: true): Whether to show the scanning overlay
- `autoTracking` (bool, default: true): Enable automatic barcode tracking
- `targetFps` (int, default: 10): Target frames per second for processing
- `sensorOrientation` (int?, default: null): Camera sensor orientation
- `lensDirection` (CameraLensDirection?, default: null): Preferred camera lens direction
- `deviceOrientation` (DeviceOrientation?, default: null): Device orientation
- `enableLogging` (bool, default: kDebugMode): Enable debug logging

#### Example

```dart
final config = StreamCameraConfig(
  showOverlay: true,
  autoTracking: true,
  targetFps: 15,
  enableLogging: true,
);
```

### OverlayType

Enumeration of supported document overlay types.

#### Available Types

- **ID Cards**: `idCardIndonesia`, `idCardISO`, `ktp`, `npwp`, `bpjs`, `ktm`
- **Passports**: `passport`, `passportPhoto`
- **Photos**: `pasFoto2x3`, `pasFoto3x4`, `pasFoto4x6`, `pasFoto2R`, `pasFoto3R`, `pasFoto4R`, `pasFoto5R`, `pasFoto8R`, `pasFoto10R`
- **Cards**: `creditCard`, `businessCard`, `simCard`
- **Documents**: `a4`, `a5`, `a6`, `familyCard`

#### Example

```dart
final config = CameraConfig(
  overlayType: OverlayType.ktp,  // Indonesian ID card
);
```

### OverlayPainter

Custom painter for rendering document overlays. This class is exported from the package and can be used for custom overlay implementations.

## Supported Platforms

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Linux
- ✅ macOS
- ✅ Windows

## Dependencies

This package uses the following key dependencies:

- `camera`: Camera functionality
- `google_mlkit_barcode_scanning`: Barcode and QR code detection
- `image`: Image processing and manipulation
- `path_provider`: File system access

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

See the [LICENSE](LICENSE) file for details.

## Getting Started

For help getting started with Flutter development, view the [online documentation](https://docs.flutter.dev), which offers tutorials, samples, guidance on mobile development, and a full API reference.
