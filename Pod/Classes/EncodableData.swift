//
//  InputGroup.swift
//  Spectra
//
//  Created by David Conner on 9/30/15.
//  Copyright © 2015 Spectra. All rights reserved.
//

import Metal
import simd

public struct InputParams {
    public var index:Int
    public var offset:Int = 0
}

public typealias SceneEncodableDataMap = [String: EncodableData]

//static let baseBufferDefaultOptions = ["default": BufferOptions(index: 0, offset: 0) as! AnyObject]

public protocol EncodableData {
    
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

public protocol EncodableBuffer: EncodableData {
    var buffer: MTLBuffer? { get set }
    var bytecount: Int? { get set }
    var resourceOptions: MTLResourceOptions? { get set }
    func prepareBuffer(device: MTLDevice, options: MTLResourceOptions)
}

public protocol EncodableInput: EncodableData {
    typealias InputType
    var data: InputType? { get set }
}

public class BaseEncodableInput<T>: EncodableInput {
    public typealias InputType = T
    public var data: InputType?
    
    public func writeCompute(encoder: MTLComputeCommandEncoder, inputParams: [String:InputParams], inputData: [String:EncodableData] = [:]) {
        encoder.setBytes(&data!, length: sizeof(T), atIndex: inputParams.values.first!.index)
    }
    
    public func writeVertex(encoder: MTLRenderCommandEncoder, inputParams: [String:InputParams], inputData: [String:EncodableData] = [:]) {
        encoder.setVertexBytes(&data!, length: sizeof(T), atIndex: inputParams.values.first!.index)
    }
    
    public func writeFragment(encoder: MTLRenderCommandEncoder, inputParams: [String:InputParams], inputData: [String:EncodableData] = [:]) {
        encoder.setFragmentBytes(&data!, length: sizeof(T), atIndex: inputParams.values.first!.index)
    }
}

public class BaseEncodableBuffer: EncodableBuffer {
    // hmm or no EncodableBuffer protocol and just pass in buffers from inputData?
    public var buffer: MTLBuffer?
    public var bytecount: Int?
    public var resourceOptions: MTLResourceOptions?
    
    public func prepareBuffer(device: MTLDevice, options: MTLResourceOptions) {
        buffer = device.newBufferWithLength(bytecount!, options: options)
    }
    
    public func writeCompute(encoder: MTLComputeCommandEncoder, inputParams: [String:InputParams], inputData: [String:EncodableData] = [:]) {
        let defaultInputParams = inputParams.values.first!
        encoder.setBuffer(buffer!, offset: defaultInputParams.offset, atIndex: defaultInputParams.index)
    }
    
    public func writeVertex(encoder: MTLRenderCommandEncoder, inputParams: [String:InputParams], inputData: [String:EncodableData] = [:]) {
        let defaultInputParams = inputParams.values.first!
        encoder.setVertexBuffer(buffer!, offset: defaultInputParams.offset, atIndex: defaultInputParams.index)
    }
    
    public func writeFragment(encoder: MTLRenderCommandEncoder, inputParams: [String:InputParams], inputData: [String:EncodableData] = [:]) {
        let defaultInputParams = inputParams.values.first!
        encoder.setFragmentBuffer(buffer!, offset: defaultInputParams.offset, atIndex: defaultInputParams.index)
    }
}

// iterates through the input data/params keys & runs write() on all of them,
// and defaults to passing all data down through the tree
public class BaseEncodableGroup: EncodableData {
    public func writeCompute(encoder: MTLComputeCommandEncoder, inputParams: [String:InputParams], inputData: [String:EncodableData]) {
        for (k,v) in inputData {
            v.writeCompute(encoder, inputParams: inputParams, inputData: inputData)
        }
    }
    
    public func writeVertex(encoder: MTLRenderCommandEncoder, inputParams: [String:InputParams], inputData: [String:EncodableData]) {
        for (k,v) in inputData {
            v.writeVertex(encoder, inputParams: inputParams, inputData: inputData)
        }
    }
    
    public func writeFragment(encoder: MTLRenderCommandEncoder, inputParams: [String:InputParams], inputData: [String:EncodableData]) {
        for (k,v) in inputData {
            v.writeFragment(encoder, inputParams: inputParams, inputData: inputData)
        }
    }
}

//class CircularBuffer: EncodableBuffer {
//    
//}

// manages writing texture data
//class TextureBuffer: SpectraBaseBuffer {
//
//}

// highly performant buffer (requires iOS and CPU/GPU integrated architecture)
// TODO: decide if generic is required?
//@available(iOS 9.0, *)
//class NoCopyBuffer<T>: EncodableBuffer {
//    var stride:Int?
//    var elementSize:Int = sizeof(T)
//    private var bufferPtr: UnsafeMutablePointer<Void>?
//    private var bufferVoidPtr: COpaquePointer?
//    private var bufferDataPtr: UnsafeMutablePointer<T>?
//    var bufferAlignment: Int = 0x1000 // for NoCopy buffers, memory needs needs to be mutliples of 4096
//    
//    func prepareMemory(bytecount: Int) {
//        self.bytecount = bytecount
//        bufferPtr = UnsafeMutablePointer<Void>.alloc(bytecount)
//        posix_memalign(&bufferPtr!, bufferAlignment, bytecount)
//        bufferVoidPtr = COpaquePointer(bufferPtr!)
//        bufferDataPtr = UnsafeMutablePointer<T>(bufferVoidPtr!)
//    }
//    
//    override func prepareBuffer(device: MTLDevice, options: MTLResourceOptions) {
//        //TODO: common deallocator?
//        buffer = device.newBufferWithBytesNoCopy(bufferPtr!, length: bytecount!, options: .StorageModeShared, deallocator: nil)
//    }
//    
//    //TODO: decide on how to use similar data access patterns when buffer is specific to a texture
//    //    override func initTexture(device: MTLDevice, textureDescriptor: MTLTextureDescriptor) {
//    //        //        texture = texBuffer!.newTextureWithDescriptor(textureDescriptor, offset: 0, bytesPerRow: calcBytesPerRow())
//    //    }
//    
//    //mechanism for writing specific bytes
//    func writeBuffer(data: [T]) {
//        memcpy(bufferDataPtr!, data, bytecount!)
//    }
//}
