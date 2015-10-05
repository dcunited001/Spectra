#include <metal_stdlib>
using namespace metal;

struct ColorVertex {
    float4 position [[ position ]];
    float4 color;
};

struct TextureVertex {
    float4 position [[ position ]];
    float4 color;
};
