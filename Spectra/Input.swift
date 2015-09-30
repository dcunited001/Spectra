//
//  SpectraInput.swift
//  Spectra
//
//  Created by David Conner on 9/25/15.
//  Copyright © 2015 Spectra. All rights reserved.
//

import Metal
import simd

protocol Input {
    func writeComputeBytes(encoder: MTLComputeCommandEncoder, index: Int)
    func writeVertexBytes(encoder: MTLRenderCommandEncoder, index: Int)
    func writeFragmentBytes(encoder: MTLRenderCommandEncoder, index: Int)
}

class BaseInput<T>: Input {
    var data: T? //TODO: can i use AnyObject here?
    
    func writeComputeBytes(encoder: MTLComputeCommandEncoder, index: Int) {
        encoder.setBytes(&data!, length: sizeof(T), atIndex: index)
    }
    
    func writeVertexBytes(encoder: MTLRenderCommandEncoder, index: Int) {
        encoder.setVertexBytes(&data!, length: sizeof(T), atIndex: index)
    }
    
    func writeFragmentBytes(encoder: MTLRenderCommandEncoder, index: Int) {
        encoder.setFragmentBytes(&data!, length: sizeof(T), atIndex: index)
    }
}

// can't use except as generic constraint =/
//protocol InputData {
//    typealias InputDataType
//    var data:InputDataType { get set }
//    func size() -> Int
//}