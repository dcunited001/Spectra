//
//  InputGroup.swift
//  Spectra
//
//  Created by David Conner on 9/30/15.
//  Copyright © 2015 Spectra. All rights reserved.
//

import Metal
import simd

// Buffer was handling BufferInputs, but i need a separate BufferGroup for this
// - most buffers will be handled through buffer providers,
// - so that will make it tricky to distribute BufferInput data changes to the buffers

// but honestly, without managing groups, Buffer/BaseBuffer don't really do much
// - except provide base classes to customize buffers for various situations (circular buffer)
// - while providing common interface to BufferProvider

protocol InputGroup {
    //TODO: brainstorm
    func writeComputeGroup(encoder: MTLComputeCommandEncoder, options: [String:InputParams])
    func writeVertexGroup(encoder: MTLRenderCommandEncoder, options: [String:InputParams])
    func writeFragmentGroup(encoder: MTLRenderCommandEncoder, options: [String:InputParams])
    
    // this doesn't allow me to recombine buffers/inputs as needed.  or select specific ones.
    
    // how to init buffer providers?  
    // - either init outside and pass in buffers to functions
    // - or init providers inside and input group manages buffer pool access
    //   - but this makes semaphore access a bit difficult to manage flow control
    //   - and this makes it difficult to share buffers between different functions in a single pass
}

struct InputParams {
    var index:Int
    var offset:Int = 0
}

//static let baseBufferDefaultOptions = ["default": BufferOptions(index: 0, offset: 0) as! AnyObject]

//protocol EncodableInput {
protocol EncodableData {
    
    // the advantage of this interface is that buffers, inputs & groups are all accessable under the same interface
    // - all input params can be passed in as hash under inputParams
    // - the actual data (buffers/inputs) can be passed in to *optional* inputData, using the same keys as params
    //   - the buffers should be passed in by reference, so buffers can be grabbed off the pool and passed in
    // - then the actual subclass implementation knows how to piece everything together
    // - a default implementation can just map up keys from inputParams & inputData
    
    // but how to write to buffers using StorageModeShared and StorageModeManaged (with pointers?)
    // - i guess just pass in the pointer and, again, the subclass implementation knows how to deal with it
    // - the memory would have to be allocated elsewhere
    
    //TODO: add options: [String: AnyObject] ?
    //TODO: add variation that accepts a block?
    func writeCompute(encoder: MTLComputeCommandEncoder, inputParams: [String:InputParams], inputData: [String:EncodableData])
    func writeVertex(encoder: MTLRenderCommandEncoder, inputParams: [String:InputParams], inputData: [String:EncodableData])
    func writeFragment(encoder: MTLRenderCommandEncoder, inputParams: [String:InputParams], inputData: [String:EncodableData])
}

protocol EncodableBuffer: EncodableData {
    var buffer: MTLBuffer? { get set }
    var bytecount: Int? { get set }
    var resourceOptions: MTLResourceOptions? { get set }
    func prepareBuffer(device: MTLDevice, options: MTLResourceOptions)
}

protocol EncodableInput: EncodableData {
    typealias InputType
    var data: InputType? { get set }
}

class BaseEncodableInput<T>: EncodableInput {
    typealias InputType = T
    var data: InputType?
    
    func writeCompute(encoder: MTLComputeCommandEncoder, inputParams: [String:InputParams], inputData: [String:EncodableData] = [:]) {
        encoder.setBytes(&data!, length: sizeof(T), atIndex: inputParams.values.first!.index)
    }
    
    func writeVertex(encoder: MTLRenderCommandEncoder, inputParams: [String:InputParams], inputData: [String:EncodableData] = [:]) {
        encoder.setVertexBytes(&data!, length: sizeof(T), atIndex: inputParams.values.first!.index)
    }
    
    func writeFragment(encoder: MTLRenderCommandEncoder, inputParams: [String:InputParams], inputData: [String:EncodableData] = [:]) {
        encoder.setFragmentBytes(&data!, length: sizeof(T), atIndex: inputParams.values.first!.index)
    }
}

class BaseEncodableBuffer: EncodableBuffer {
    // hmm or no EncodableBuffer protocol and just pass in buffers from inputData?
    var buffer: MTLBuffer?
    var bytecount: Int?
    var resourceOptions: MTLResourceOptions?
    
    func prepareBuffer(device: MTLDevice, options: MTLResourceOptions) {
        buffer = device.newBufferWithLength(bytecount!, options: options)
    }
    
    func writeCompute(encoder: MTLComputeCommandEncoder, inputParams: [String:InputParams], inputData: [String:EncodableData] = [:]) {
        let defaultInputParams = inputParams.values.first!
        encoder.setBuffer(buffer!, offset: defaultInputParams.offset, atIndex: defaultInputParams.index)
    }
    
    func writeVertex(encoder: MTLRenderCommandEncoder, inputParams: [String:InputParams], inputData: [String:EncodableData] = [:]) {
        let defaultInputParams = inputParams.values.first!
        encoder.setVertexBuffer(buffer!, offset: defaultInputParams.offset, atIndex: defaultInputParams.index)
    }
    
    func writeFragment(encoder: MTLRenderCommandEncoder, inputParams: [String:InputParams], inputData: [String:EncodableData] = [:]) {
        let defaultInputParams = inputParams.values.first!
        encoder.setFragmentBuffer(buffer!, offset: defaultInputParams.offset, atIndex: defaultInputParams.index)
    }
}

// iterates through the input data/params keys & runs write() on all of them, 
// and defaults to passing all data down through the tree
class BaseEncodableGroup: EncodableData {
    func writeCompute(encoder: MTLComputeCommandEncoder, inputParams: [String:InputParams], inputData: [String:EncodableData]) {
        for (k,v) in inputData {
            v.writeCompute(encoder, inputParams: inputParams, inputData: inputData)
        }
    }
    
    func writeVertex(encoder: MTLRenderCommandEncoder, inputParams: [String:InputParams], inputData: [String:EncodableData]) {
        for (k,v) in inputData {
            v.writeVertex(encoder, inputParams: inputParams, inputData: inputData)
        }
    }
    
    func writeFragment(encoder: MTLRenderCommandEncoder, inputParams: [String:InputParams], inputData: [String:EncodableData]) {
        for (k,v) in inputData {
            v.writeFragment(encoder, inputParams: inputParams, inputData: inputData)
        }
    }
}

