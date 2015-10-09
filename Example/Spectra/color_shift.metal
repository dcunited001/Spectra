//
//  color_shift.metal
//  Spectra
//
//  Created by David Conner on 10/6/15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct ColorVertex {
    float4 position [[ position ]];
    float4 color;
};

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
        vout.color = shiftColorWithMVP(*cin, mvp);
    
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
        vout.color = shiftColorContinuousWithMVP(*cin, mvp);
    
    return vout;
}
