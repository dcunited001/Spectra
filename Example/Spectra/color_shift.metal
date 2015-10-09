//
//  color_shift.metal
//  Spectra
//
//  Created by David Conner on 10/6/15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

typedef struct {
    float4 position [[attribute(0)]];
    float4 rgba [[attribute(1)]];
    float4 texcoord [[attribute(2)]];
} ColorVertex;

typedef struct {
    float4 position [[ position ]];
    float4 rgba;
} ColorVertexOut;

//typedef struct {
//    float2 position [[attribute(0)]];
//    float2 texCoord [[attribute(1)]];
//} VertexData;
//
//typedef struct {
//    float4 position [[position]];
//    float2 texCoord;
//} VertexOut;

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

vertex ColorVertexOut basicColorVertex
(
 const device float4* vin [[ buffer(0) ]],
 const device float4* cin [[ buffer(1) ]],
 const device float4x4& mvp [[ buffer(2) ]],
 unsigned int vid [[ vertex_id ]])
{
    ColorVertexOut vOut;
    vOut.position = mvp * vin[vid];
    vOut.rgba = cin[vid];
    
    return vOut;
}

fragment half4 basicColorFragment
(
 ColorVertexOut interpolated [[ stage_in ]])
{
    return half4(interpolated.rgba[0], interpolated.rgba[1], interpolated.rgba[2], interpolated.rgba[3]);
}

vertex ColorVertexOut basicColorShiftedVertex
(
 const device float4* vin [[ buffer(0) ]],
 const device float4* cin [[ buffer(1) ]],
 const device float4x4& mvp [[ buffer(2) ]],
 unsigned int vid [[ vertex_id ]])
{
    ColorVertexOut vout;
    vout.position = mvp * vin[vid];
        vout.rgba = shiftColorWithMVP(*cin, mvp);
    
    return vout;
}

vertex ColorVertexOut basicColorShiftedContinuousVertex
(
 const device float4* vin [[ buffer(0) ]],
 const device float4* cin [[ buffer(1) ]],
 const device float4x4& mvp [[ buffer(2) ]],
 unsigned int vid [[ vertex_id ]])
{
    ColorVertexOut vout;
    
    vout.position = mvp * vin[vid];
        vout.rgba = shiftColorContinuousWithMVP(*cin, mvp);
    
    return vout;
}
