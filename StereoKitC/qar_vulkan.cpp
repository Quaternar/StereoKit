/* Quaternar addition, not part of upstream StereoKit. See qar_vulkan.h. */

#include "qar_vulkan.h"

#include "_stereokit.h"
#include "log.h"

#include <sk_renderer.h>

namespace sk {

static qar_vulkan_device_picker_t qar_vk_picker           = nullptr;
static void                      *qar_vk_picker_user_data = nullptr;

///////////////////////////////////////////

void qar_vulkan_set_device_picker(qar_vulkan_device_picker_t picker, void *user_data) {
	if (sk_is_initialized()) {
		log_err("qar_vulkan_set_device_picker must be called BEFORE StereoKit initialization!");
		return;
	}
	qar_vk_picker           = picker;
	qar_vk_picker_user_data = user_data;
}

///////////////////////////////////////////

void qar_vulkan_apply_device_picker(skr_settings_t *ref_settings) {
#if defined(SKR_VK)
	// In XR the runtime's device is the only valid one, and the vulkan_enable
	// extension has already installed its callback by now, so an app pick never
	// gets to override it.
	if (qar_vk_picker == nullptr || ref_settings->device_init_callback != nullptr) return;

	ref_settings->device_init_callback = [](void *vk_instance, void *user_data) {
		skr_device_request_t request = {};
		request.physical_device = qar_vk_picker(vk_instance, user_data);
		return request;
	};
	ref_settings->device_init_user_data = qar_vk_picker_user_data;
#endif
}

} // namespace sk
