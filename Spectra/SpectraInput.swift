//
//  SpectraInput.swift
//  Spectra
//
//  Created by David Conner on 9/25/15.
//  Copyright © 2015 Spectra. All rights reserved.
//

import Metal
import simd

protocol SpectraInput {
    //TODO: evaluate generic here??
    typealias InputType
    
    var data: InputType? { get set }
    var bufferId: Int? { get set }
    
    func writeComputeBytes(encoder: MTLComputeCommandEncoder)
    func writeVertexBytes(encoder: MTLRenderCommandEncoder)
    func writeFragmentBytes(encoder: MTLRenderCommandEncoder)
}

class SpectraBaseInput<T>: SpectraInput {
    typealias InputType = T
    
    var data: InputType? //TODO: can i use AnyObject here?
    var bufferId: Int?
    
    func writeComputeBytes(encoder: MTLComputeCommandEncoder) {
        encoder.setBytes(&data!, length: sizeof(InputType), atIndex: bufferId!)
    }
    
    func writeVertexBytes(encoder: MTLRenderCommandEncoder) {
        encoder.setVertexBytes(&data!, length: sizeof(InputType), atIndex: bufferId!)
    }
    
    func writeFragmentBytes(encoder: MTLRenderCommandEncoder) {
        encoder.setFragmentBytes(&data!, length: sizeof(InputType), atIndex: bufferId!)
    }
}

