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

	float4 sampledColor;
	float sampledDepth;

	if (input.view_id == 0) // left eye
	{
		sampledColor = sk_cubemap_color_left.Sample(sk_cubemap_color_left_sampler, uvCoordinates);
		sampledDepth = sk_cubemap_depth_left.Sample(sk_cubemap_depth_left_sampler, uvCoordinates).x;
	}
	else // right eye
	{
		sampledColor = sk_cubemap_color_right.Sample(sk_cubemap_color_right_sampler, uvCoordinates);
		sampledDepth = sk_cubemap_depth_right.Sample(sk_cubemap_depth_right_sampler, uvCoordinates).x;
	}

	psOut result;

	// color
	result.color = sampledColor;

	// linearize depth
	float linearDepth;
	if (sk_source_near < sk_source_far) // standard Z
	{
		if (isinf(sk_source_far)) // infinity
		{
			linearDepth = sk_source_near / sampledDepth; // TODO: not tested
		}
		else
		{
			linearDepth = (2.0f * sk_source_near * sk_source_far) / (sk_source_far + sk_source_near - sampledDepth * (sk_source_far - sk_source_near)); // TODO: not tested
		}
	}
	else // reversed Z
	{
		if (isinf(sk_source_near)) // infinity
		{
			linearDepth = sk_source_far / sampledDepth;
		}
		else
		{
			linearDepth = (2.0f * sk_source_far * sk_source_near) / (sk_source_far - sk_source_near + sampledDepth * (sk_source_near - sk_source_far)); // TODO: not tested
		}
	}

	// convert back to StereoKit depth
	const float unlinearizedDepth = (sk_far + sk_near) / (sk_far - sk_near) + (1 / linearDepth) * ((-2.0f * sk_far * sk_near) / (sk_far - sk_near)); // range [-1; 1]
	result.depth = (unlinearizedDepth + 1.0f) / 2.0f; // range [0; 1]

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
