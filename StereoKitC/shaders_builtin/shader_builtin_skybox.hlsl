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
	psOut result{};
	result.color = sk_cubemap.Sample(sk_cubemap_s, float2(input.pos.x / 1500, input.pos.y / 1000)); // TODO: change constants 1500 and 1000
	result.depth = sk_cubemap_depth.Sample(sk_cubemap_depth_s, float2(input.pos.x / 1500, input.pos.y / 1000));

	return result;
}