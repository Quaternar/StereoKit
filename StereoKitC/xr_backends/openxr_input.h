#pragma once

namespace sk {

bool oxri_init        ();
void oxri_shutdown    ();
void oxri_update_frame();
void oxri_update_poses();
void oxri_update_interaction_profile();

extern bool xrc_aim_ready[2];

} // namespace sk
