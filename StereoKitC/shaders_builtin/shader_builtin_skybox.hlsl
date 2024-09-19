#include "stereokit.hlsli"

struct vsIn {
	float4 pos : SV_Position;
};
struct psIn {
	float4 pos  : SV_Position;
	float3 norm : NORMAL0;
	uint view_id : SV_RenderTargetArrayIndex;
};

struct psOut {
	float4 color : SV_Target;
	float  depth : SV_Depth;
};

psIn vs(vsIn input, uint id : SV_InstanceID) {
	psIn o;
	o.view_id = id % sk_view_count;
	id        = id / sk_view_count;
	o.pos     = float4(input.pos.xy, 1, 1);

	float4 proj_inv = mul(o.pos, sk_proj_inv[o.view_id]);
	o.norm = mul(float4(proj_inv.xyz, 0), transpose(sk_view[o.view_id])).xyz;
	return o;
}

psOut ps(psIn input) {
	float2 uvCoordinates = float2(input.pos.x / sk_viewport_width, input.pos.y / sk_viewport_height);

	float4 color;
	float depth;

	if (input.view_id == 0) // left eye
	{
		color = sk_cubemap_color_left.Sample(sk_cubemap_color_left_sampler, uvCoordinates);
		depth = sk_cubemap_depth_left.Sample(sk_cubemap_depth_left_sampler, uvCoordinates).x;
	}
	else // right eye
	{
		color = sk_cubemap_color_right.Sample(sk_cubemap_color_right_sampler, uvCoordinates);
		depth = sk_cubemap_depth_right.Sample(sk_cubemap_depth_right_sampler, uvCoordinates).x;
	}

	psOut result;
	result.color = color;
	result.depth = depth;

	// NDC
	float2 ndc;
	ndc.x = uvCoordinates.x * 2.0f - 1.0f;
	ndc.y = 1.0f - uvCoordinates.y * 2.0f; // flip Y

	// Homogeneous coordinates
	float4 homogeneous = float4(ndc.x, ndc.y, result.depth, 1.0f);

	// View space
	float4 viewPosition = mul(homogeneous, sk_proj_inv[input.view_id]);
	viewPosition /= viewPosition.w;

	// World space
	float4 worldPosition = mul(viewPosition, sk_view_inv[input.view_id]);

	// Check whether world space coordinates are within table bounds
	if (worldPosition.x < sk_table_min.x || worldPosition.x > sk_table_max.x ||
		worldPosition.y < sk_table_min.y || worldPosition.y > sk_table_max.y ||
		worldPosition.z < sk_table_min.z || worldPosition.z > sk_table_max.z)
	{
		discard;
	}

	return result;
}
