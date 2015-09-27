//
//  SpectraBuffer.swift
//  Spectra
//
//  Created by David Conner on 9/25/15.
//  Copyright © 2015 Spectra. All rights reserved.
//

import Metal
import simd

protocol SpectraBuffer {
    var buffer: MTLBuffer? { get set }
    var bufferId: Int? { get set }
    var bytecount: Int? { get set }
    var resourceOptions: MTLResourceOptions? { get set }
    
    func prepareBuffer(device: MTLDevice, options: MTLResourceOptions)
    func writeCompute(encoder: MTLComputeCommandEncoder)
    func writeComputeParams(encoder: MTLComputeCommandEncoder)
    func writeVertex(encoder: MTLRenderCommandEncoder)
    func writeVertexParams(encoder: MTLRenderCommandEncoder)
    func writeFragment(encoder: MTLRenderCommandEncoder)
    func writeFragmentParams(encoder: MTLRenderCommandEncoder)
}

class SpectraBaseBuffer: SpectraBuffer {
    var buffer: MTLBuffer?
    var bufferId: Int?
    var bytecount: Int?
    var resourceOptions: MTLResourceOptions?
    
    func prepareBuffer(device: MTLDevice, options: MTLResourceOptions) {
        //either set buffer/bufferId or subclass and configure it
    }
    
    func writeCompute(encoder: MTLComputeCommandEncoder) {
        writeComputeParams(encoder)
        encoder.setBuffer(buffer!, offset: 0, atIndex: bufferId!)
    }
    
    func writeComputeParams(encoder: MTLComputeCommandEncoder) {
        // override in subclass
    }
    
    func writeVertex(encoder: MTLRenderCommandEncoder) {
        writeVertexParams(encoder)
        encoder.setVertexBuffer(buffer!, offset: 0, atIndex: bufferId!)
    }
    
    func writeVertexParams(encoder: MTLRenderCommandEncoder) {
        // override in subclass
    }
    
    func writeFragment(encoder: MTLRenderCommandEncoder) {
        writeFragmentParams(encoder)
        encoder.setFragmentBuffer(buffer!, offset: 0, atIndex: bufferId!)
    }
    
    func writeFragmentParams(encoder: MTLRenderCommandEncoder) {
        // override in subclass
    }
}

class SpectraCircularBuffer: SpectraBaseBuffer {
    
}



// manages writing texture data
//class TextureBuffer: SpectraBaseBuffer {
//
//}

// highly performant buffer (requires iOS and CPU/GPU integrated architecture)
// TODO: decide if generic is required?
@available(iOS 9.0, *)
class NoCopyBuffer<T>: SpectraBaseBuffer {
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




