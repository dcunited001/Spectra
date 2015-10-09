//
//  DataEncoding.swift
//  Spectra
//
//  Created by David Conner on 10/9/15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import Metal
import simd

struct CommonVertex {
    var pos: float4
    var rgba: float4
    var tex: float2
    var extra: float2
}

// swift equivalent to offsetof() ??
// if i just had offsetof() i could mostly generate everything dynamically, given the struct name

class VertexDescriptorGenerator {
    class func commonVertexDescriptor(layoutDescriptor: MTLVertexBufferLayoutDescriptor? = nil) -> MTLVertexDescriptor {
        let vertexDesc = MTLVertexDescriptor()
        let positionDesc = MTLVertexAttributeDescriptor()
        positionDesc.format = .Float4
        positionDesc.offset = 0
        positionDesc.bufferIndex = 0
        
        let rgbaDesc = MTLVertexAttributeDescriptor()
        rgbaDesc.format = .Float4
        rgbaDesc.offset = 32
        rgbaDesc.bufferIndex = 0
        
        let texDesc = MTLVertexAttributeDescriptor()
        texDesc.format = .Float2
        texDesc.offset = 64
        texDesc.bufferIndex = 0
        
        let extraDesc = MTLVertexAttributeDescriptor()
        extraDesc.format = .Float2
        extraDesc.offset = 80
        extraDesc.bufferIndex = 0
        
        vertexDesc.attributes[0] = positionDesc
        vertexDesc.attributes[1] = rgbaDesc
        vertexDesc.attributes[2] = texDesc
        vertexDesc.attributes[3] = extraDesc
        
        var layoutDesc = layoutDescriptor
        
        if (layoutDesc == nil) {
            layoutDesc = MTLVertexBufferLayoutDescriptor()
            layoutDesc!.stride = sizeof(CommonVertex)
            layoutDesc!.stepFunction = .PerVertex
            layoutDesc!.stepRate = 1
        }
        
        vertexDesc.layouts[0] = layoutDesc!
        return vertexDesc
    }
}
