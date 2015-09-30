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
    var bufferId: Int? { get set }
    func writeComputeBytes(encoder: MTLComputeCommandEncoder, inputOptions:[String:AnyObject])
    func writeVertexBytes(encoder: MTLRenderCommandEncoder, inputOptions:[String:AnyObject])
    func writeFragmentBytes(encoder: MTLRenderCommandEncoder, inputOptions:[String:AnyObject])
}

// can't use except as generic constraint =/
//protocol InputData {
//    typealias InputDataType
//    var data:InputDataType { get set }
//    func size() -> Int
//}

struct BufferInputOptions {
    var index:Int
}

class BaseInput<T>: Input {
    var data: T? //TODO: can i use AnyObject here?
    static let defaultInputOptions = ["default": BufferInputOptions(index: 0)]
    
    func writeComputeBytes(encoder: MTLComputeCommandEncoder, inputOptions:[String:AnyObject] = [:]) {
        encoder.setBytes(&data!, length: sizeof(T), atIndex: bufferId!)
    }
    
    func writeVertexBytes(encoder: MTLRenderCommandEncoder, inputOptions:[String:AnyObject] = [:]) {
        encoder.setVertexBytes(&data!, length: sizeof(T), atIndex: bufferId!)
    }
    
    func writeFragmentBytes(encoder: MTLRenderCommandEncoder, inputOptions:[String:AnyObject] = [:]) {
        encoder.setFragmentBytes(&data!, length: sizeof(T), atIndex: bufferId!)
    }
}
