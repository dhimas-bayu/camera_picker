#include "include/camera_picker/camera_picker_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "camera_picker_plugin.h"

void CameraPickerPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  camera_picker::CameraPickerPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
