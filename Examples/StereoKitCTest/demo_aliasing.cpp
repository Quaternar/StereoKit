#include "demo_aliasing.h"

#include <stereokit.h>
#include <stereokit_ui.h>
#include <stdio.h>

#include <lib/include/openxr/openxr.h>

using namespace sk;

///////////////////////////////////////////

void demo_aliasing_init() {
}

///////////////////////////////////////////

XrReprojectionModeMSFT selected_reprojection = XrReprojectionModeMSFT::XR_REPROJECTION_MODE_MAX_ENUM_MSFT;

void demo_aliasing_update() {
	static pose_t window_pose =
		pose_t{ {0.25,0.25,-0.25f}, quat_lookat({0.25,0.25,-0.25f}, {0,0.25,0}) };

	static float render_scale       =        render_get_scaling();
	static float render_multisample = (float)render_get_multisample();

	bool32_t reprojection_none = selected_reprojection == XrReprojectionModeMSFT::XR_REPROJECTION_MODE_MAX_ENUM_MSFT;
	bool32_t reprojection_depth = selected_reprojection == XrReprojectionModeMSFT::XR_REPROJECTION_MODE_DEPTH_MSFT;
	bool32_t reprojection_planar_from_depth = selected_reprojection == XrReprojectionModeMSFT::XR_REPROJECTION_MODE_PLANAR_FROM_DEPTH_MSFT;
	bool32_t reprojection_planar_manual = selected_reprojection == XrReprojectionModeMSFT::XR_REPROJECTION_MODE_PLANAR_MANUAL_MSFT;
	bool32_t reprojection_orientation_only = selected_reprojection == XrReprojectionModeMSFT::XR_REPROJECTION_MODE_ORIENTATION_ONLY_MSFT;

	ui_window_begin("Reprojection", window_pose);

	if (ui_toggle("None", reprojection_none))
	{
		selected_reprojection = XrReprojectionModeMSFT::XR_REPROJECTION_MODE_MAX_ENUM_MSFT;
	}

	if (ui_toggle("Depth", reprojection_depth))
	{
		selected_reprojection = XrReprojectionModeMSFT::XR_REPROJECTION_MODE_DEPTH_MSFT;
	}

	if (ui_toggle("Planar from depth", reprojection_planar_from_depth))
	{
		selected_reprojection = XrReprojectionModeMSFT::XR_REPROJECTION_MODE_PLANAR_FROM_DEPTH_MSFT;
	}

	if (ui_toggle("Manual", reprojection_planar_manual))
	{
		selected_reprojection = XrReprojectionModeMSFT::XR_REPROJECTION_MODE_PLANAR_MANUAL_MSFT;
	}

	if (ui_toggle("Orientation only", reprojection_orientation_only))
	{
		selected_reprojection = XrReprojectionModeMSFT::XR_REPROJECTION_MODE_ORIENTATION_ONLY_MSFT;
	}

	if (selected_reprojection != XrReprojectionModeMSFT::XR_REPROJECTION_MODE_MAX_ENUM_MSFT)
	{
		XrCompositionLayerReprojectionInfoMSFT reprojectionInfo{};
		reprojectionInfo.type = XR_TYPE_COMPOSITION_LAYER_REPROJECTION_INFO_MSFT;
		reprojectionInfo.next = nullptr;
		reprojectionInfo.reprojectionMode = selected_reprojection;

		backend_openxr_end_frame_chain(&reprojectionInfo, sizeof(reprojectionInfo));
	}

	ui_window_end();
}

///////////////////////////////////////////

void demo_aliasing_shutdown() {
}