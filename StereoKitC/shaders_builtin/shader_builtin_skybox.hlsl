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
	float2 uvCoordinates = float2(input.pos.x / 1500, input.pos.y / 1000); // TODO: change constants 1500 and 1000

	float4 color;
	float depth;

	if (input.view_id == 0) // left eye
	{
		color = sk_cubemap_color_left.Sample(sk_cubemap_color_left_sampler, uvCoordinates);
		depth = sk_cubemap_depth_left.Sample(sk_cubemap_depth_left_sampler, uvCoordinates);
	}
	else // right eye
	{
		color = sk_cubemap_color_right.Sample(sk_cubemap_color_right_sampler, uvCoordinates);
		depth = sk_cubemap_depth_right.Sample(sk_cubemap_depth_right_sampler, uvCoordinates);
	}

	psOut result;
	result.color = color;
	result.depth = depth;

	return result;
}