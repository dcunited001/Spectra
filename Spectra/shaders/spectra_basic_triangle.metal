#include <metal_stdlib>
#include "spectra_common.metal"
using namespace metal;

vertex ColorVertex basicColorVertex
(
 const device float4* vin [[ buffer(0) ]],
 const device float4* cin [[ buffer(1) ]],
 const device float4x4& mvp [[ buffer(2) ]],
 unsigned int vid [[ vertex_id ]])
{
    ColorVertex vOut;
    vOut.position = mvp * vin[vid];
    vOut.color = cin[vid];
    
    return vOut;
}

fragment half4 basicColorFragment
(
 ColorVertex interpolated [[ stage_in ]])
{
    return half4(interpolated.color[0], interpolated.color[1], interpolated.color[2], interpolated.color[3]);
}

vertex ColorVertex basicColorShiftedVertex
(
 const device float4* vin [[ buffer(0) ]],
 const device float4* cin [[ buffer(1) ]],
 const device float4x4& mvp [[ buffer(2) ]],
 unsigned int vid [[ vertex_id ]])
{
    ColorVertex vout;
    vout.position = mvp * vin[vid];
    
    vout.color = colorShiftWithMVP(*cin, mvp);
    
    return vout;
}

vertex ColorVertex basicColorShiftedContinuousVertex
(
 const device float4* vin [[ buffer(0) ]],
 const device float4* cin [[ buffer(1) ]],
 const device float4x4& mvp [[ buffer(2) ]],
 unsigned int vid [[ vertex_id ]])
{
    ColorVertex vout;
    
    vout.position = mvp * vin[vid];
    vout.color = colorShiftContinuousWithMVP(*cin, mvp);
    
    return vout;
}
