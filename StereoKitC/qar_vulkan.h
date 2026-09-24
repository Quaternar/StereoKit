/* Quaternar addition, not part of upstream StereoKit. Kept in its own file so
   an upstream merge never has to resolve it. */

#pragma once

#include "stereokit.h"

struct skr_settings_t;

namespace sk {

/*Picks the GPU StereoKit renders with. Called once, after the VkInstance
  exists and before the VkDevice is created. Return the VkPhysicalDevice to
  render with, or null to let sk_renderer score the enumerated devices as it
  normally would.*/
typedef void *(*qar_vulkan_device_picker_t)(void *vk_instance, void *user_data);

/*Hands StereoKit the GPU to render with instead of letting sk_renderer score
  the enumerated devices. Quaternar adopts StereoKit's Vulkan device for
  streaming interop, and every shared texture and semaphore is bound to the
  adapter the session already picked, so a different GPU yields handles the
  rest of the pipeline cannot import. Call this BEFORE StereoKit
  initialization. An XR runtime dictates the device itself, and its choice
  still wins over this one.*/
SK_API void qar_vulkan_set_device_picker(qar_vulkan_device_picker_t picker, void *user_data);

/*Internal: hands the picker to sk_renderer while its settings are assembled.*/
void qar_vulkan_apply_device_picker(skr_settings_t *ref_settings);

} // namespace sk
