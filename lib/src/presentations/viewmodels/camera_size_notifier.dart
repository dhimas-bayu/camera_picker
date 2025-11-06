import 'package:flutter/widgets.dart';

class CameraSizeNotifier extends ChangeNotifier {
  Size? _previewSize;

  Size? get size => _previewSize;

  void setPreviewSize(Size? value) {
    if (_previewSize == value) return;
    _previewSize = value;
    notifyListeners();
  }
}
