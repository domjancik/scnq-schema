#ifndef SBUFFER_FXH
#include <packs\happy.fxh\sbuffer.fxh>
#endif

RWStructuredBuffer<float3> output : BACKBUFFER;

StructuredBuffer<float4x4> bTransformA;
StructuredBuffer<float3> xyzb;
float4x4 dtA;
float3 xyz;


uint threadCount;
#ifndef GROUPSIZE 
#define GROUPSIZE 128,1,1
#endif

[numthreads(GROUPSIZE)]
void CSmul( uint3 dtid : SV_DispatchThreadID)
{ 
	if (dtid.x >= threadCount) { return; }
	float4x4 mat = sbLoad(bTransformA, dtA, dtid.x);
	float3 pos = sbLoad(xyzb, xyz, dtid.x);
	output[dtid.x] = (mul(float4(pos, 1), mat)).xyz;
}



technique11 Multiply
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CSmul() ) );
	}
}







