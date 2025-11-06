//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <camera_picker/camera_picker_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) camera_picker_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "CameraPickerPlugin");
  camera_picker_plugin_register_with_registrar(camera_picker_registrar);
}
