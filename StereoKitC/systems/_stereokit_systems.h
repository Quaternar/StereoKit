/* SPDX-License-Identifier: MIT */
/* The authors below grant copyright rights under the MIT license:
 * Copyright (c) 2024 Nick Klingensmith
 * Copyright (c) 2024 Qualcomm Technologies, Inc.
 */

#pragma once

namespace sk {

typedef struct sk_external_platform_t {
	bool (*func_initialize)(void);
	void (*func_step_begin)(void);
	void (*func_step_end)(void);
	void (*func_shutdown)(void);
} sk_external_platform_t;

bool stereokit_systems_register(sk_external_platform_t* platform = nullptr);

}
