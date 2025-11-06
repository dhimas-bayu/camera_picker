#ifndef FLUTTER_PLUGIN_CAMERA_PICKER_PLUGIN_H_
#define FLUTTER_PLUGIN_CAMERA_PICKER_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace camera_picker {

class CameraPickerPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  CameraPickerPlugin();

  virtual ~CameraPickerPlugin();

  // Disallow copy and assign.
  CameraPickerPlugin(const CameraPickerPlugin&) = delete;
  CameraPickerPlugin& operator=(const CameraPickerPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace camera_picker

#endif  // FLUTTER_PLUGIN_CAMERA_PICKER_PLUGIN_H_
