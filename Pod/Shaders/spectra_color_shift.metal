//
//  spectra_color_shift.metal
//  Pods
//
//  Created by David Conner on 10/5/15.
//
//

#include <metal_stdlib>
using namespace metal;

// reuses the uniforms matrix to shift color as though it's a coordinate system
extern float4 shiftColorWithMVP
(
 float4 color,
 float4x4 mvp)
{
    int quanta = 8;
    float fQuanta = float(quanta);
    
    float4 colorOut = mvp * float4(color.x, color.y, color.z, 1.0);
    return float4(int(colorOut.x * quanta)/fQuanta,
                  int(colorOut.y * quanta)/fQuanta,
                  int(colorOut.z * quanta)/fQuanta,
                  color.w);
}

extern float4 shiftColorContinuousWithMVP
(
 const float4 color,
 const float4x4 mvp)
{
    float4 colorOut = mvp * float4(color.x, color.y, color.z, 1.0);
    return float4(colorOut.r,
                  colorOut.g,
                  colorOut.b,
                  color.a);
}

//float4 colorShiftByDistance