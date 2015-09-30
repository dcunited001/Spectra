//
//  SpectraBuffer.swift
//  Spectra
//
//  Created by David Conner on 9/25/15.
//  Copyright © 2015 Spectra. All rights reserved.
//

import Metal
import simd

protocol Buffer {
    var buffer: MTLBuffer? { get set }
    var bytecount: Int? { get set }
    var resourceOptions: MTLResourceOptions? { get set }
    
    func prepareBuffer(device: MTLDevice, options: MTLResourceOptions)
    func writeCompute(encoder: MTLComputeCommandEncoder, bufferOptions: [String:AnyObject])
    func writeComputeInputs(encoder: MTLComputeCommandEncoder, inputOptions:[String:AnyObject])
    func writeVertex(encoder: MTLRenderCommandEncoder, bufferOptions: [String:AnyObject])
    func writeVertexInputs(encoder: MTLRenderCommandEncoder, inputOptions:[String:AnyObject])
    func writeFragment(encoder: MTLRenderCommandEncoder, bufferOptions: [String:AnyObject])
    func writeFragmentInputs(encoder: MTLRenderCommandEncoder, inputOptions:[String:AnyObject])
}

// so, right now, this handles a buffer with multiple param sets, 
// - the buffer ID of which can be set at runtime
// - but, how to get this to work with multiple correlated buffers that share input params?

// if [String:AnyObject] doesn't work out for bufferOptions,
// - then [String:BufferInputOption]
struct BufferOptions {
    var index:Int
    var offset:Int
}

struct BufferInputOptions {
    var index:Int
}

class BaseBuffer: Buffer {
    var buffer: MTLBuffer?
    var bytecount: Int?
    var resourceOptions: MTLResourceOptions?
    
    static let baseBufferDefaultOptions = ["default": BufferOptions(index: 0, offset: 0) as! AnyObject]
    
    func prepareBuffer(device: MTLDevice, options: MTLResourceOptions) {
        buffer = device.newBufferWithLength(bytecount!, options: options)
    }
    
    func writeCompute(encoder: MTLComputeCommandEncoder, bufferOptions: [String:AnyObject] = baseBufferDefaultOptions) {
        let defaultBufferOptions = bufferOptions["default"] as! BufferOptions
        encoder.setBuffer(buffer!, offset: defaultBufferOptions.offset, atIndex: defaultBufferOptions.index as! Int)
    }
    
    func writeComputeInputs(encoder: MTLComputeCommandEncoder, inputOptions:[String:AnyObject] = [:]) {
        // override in subclass
    }
    
    func writeVertex(encoder: MTLRenderCommandEncoder, bufferOptions: [String:AnyObject] = baseBufferDefaultOptions) {
        let defaultBufferOptions = bufferOptions["default"] as! BufferOptions
        encoder.setVertexBuffer(buffer!, offset: defaultBufferOptions.offset, atIndex: defaultBufferOptions.index as! Int)
    }
    
    func writeVertexInputs(encoder: MTLRenderCommandEncoder, inputOptions:[String:AnyObject] = [:]) {
        // override in subclass
    }
    
    func writeFragment(encoder: MTLRenderCommandEncoder, bufferOptions: [String:AnyObject] = baseBufferDefaultOptions) {
        let defaultBufferOptions = bufferOptions["default"] as! BufferOptions
        encoder.setVertexBuffer(buffer!, offset: defaultBufferOptions.offset, atIndex: defaultBufferOptions.index as! Int)
    }
    
    func writeFragmentInputs(encoder: MTLRenderCommandEncoder, inputOptions:[String:AnyObject] = [:]) {
        // override in subclass
    }
}

class CircularBuffer: BaseBuffer {
    
}

// manages writing texture data
//class TextureBuffer: SpectraBaseBuffer {
//
//}

// highly performant buffer (requires iOS and CPU/GPU integrated architecture)
// TODO: decide if generic is required?
@available(iOS 9.0, *)
class NoCopyBuffer<T>: BaseBuffer {
    var stride:Int?
    var elementSize:Int = sizeof(T)
    private var bufferPtr: UnsafeMutablePointer<Void>?
    private var bufferVoidPtr: COpaquePointer?
    private var bufferDataPtr: UnsafeMutablePointer<T>?
    var bufferAlignment: Int = 0x1000 // for NoCopy buffers, memory needs needs to be mutliples of 4096
    
    func prepareMemory(bytecount: Int) {
        self.bytecount = bytecount
        bufferPtr = UnsafeMutablePointer<Void>.alloc(bytecount)
        posix_memalign(&bufferPtr!, bufferAlignment, bytecount)
        bufferVoidPtr = COpaquePointer(bufferPtr!)
        bufferDataPtr = UnsafeMutablePointer<T>(bufferVoidPtr!)
    }
    
    override func prepareBuffer(device: MTLDevice, options: MTLResourceOptions) {
        //TODO: common deallocator?
        buffer = device.newBufferWithBytesNoCopy(bufferPtr!, length: bytecount!, options: .StorageModeShared, deallocator: nil)
    }
    
    //TODO: decide on how to use similar data access patterns when buffer is specific to a texture
    //    override func initTexture(device: MTLDevice, textureDescriptor: MTLTextureDescriptor) {
    //        //        texture = texBuffer!.newTextureWithDescriptor(textureDescriptor, offset: 0, bytesPerRow: calcBytesPerRow())
    //    }
    
    //mechanism for writing specific bytes
    func writeBuffer(data: [T]) {
        memcpy(bufferDataPtr!, data, bytecount!)
    }
}




