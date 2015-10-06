//
//  SpectraBufferProvider.swift
//  Spectra
//
//  Created by David Conner on 9/28/15.
//  Copyright © 2015 Spectra. All rights reserved.
//

//TODO: buffer providers for input to render/compute functions
// - reusing a pool of these buffers should greatly increase performance
// - but locks us down to a particular size of buffer ... or does it??
// - if you just instantiate the largest buffer you'll need, then no.
// - however, it does make it more difficult to specialize the behavior you need
//   for the buffer's memory (StorageModeShared, posix_memalign, etc.)
// - and thus, it makes it more difficult to develop rendering behavior, as your
//   nodes need to be aware of the implementation you're using

import Metal

// N.B. planning on always accessing Buffer via BufferProvider (and MTLBuffer via Buffer)
// - so that interface is consistent and so that stuff can easily be built on top of one thing

protocol BufferPool: class {
    var bytecount:Int { get set }
    var buffersCount:Int { get set }
    var buffersIndex:Int { get set }
    var buffers: [EncodableBuffer] { get set } // private
    
    // N.B. must deinit resources!
    
    init(device: MTLDevice, bytecount: Int, buffersCount: Int, options: MTLResourceOptions)
    func prepareBufferPool(device: MTLDevice, bytecount: Int, options: MTLResourceOptions)
    func prepareBufferPool(device: MTLDevice, bytecount: Int, options: MTLResourceOptions, createWith: (Self) -> EncodableBuffer)
    func createBuffer(device: MTLDevice, bytecount: Int, options: MTLResourceOptions) -> EncodableBuffer
    func createBuffer(device: MTLDevice, bytecount: Int, options: MTLResourceOptions, createWith: (Self) -> EncodableBuffer) -> EncodableBuffer
    
    func getBuffer() -> EncodableBuffer
    func getBuffer(bufferIndex: Int) -> EncodableBuffer
}

//TODO: must dispatch_semaphore_signal from view render() !!!

extension BufferPool {
    func prepareBufferPool(device: MTLDevice, bytecount: Int, options: MTLResourceOptions = .CPUCacheModeDefaultCache) {
        for _ in 0...buffersCount-1 {
            let buffer = createBuffer(device, bytecount: self.bytecount, options: options)
            buffers.append(buffer)
        }
    }
    
    func prepareBufferPool(device: MTLDevice, bytecount: Int, options: MTLResourceOptions = .CPUCacheModeDefaultCache, createWith: (Self) -> EncodableBuffer) {
        for _ in 0...buffersCount-1 {
            let buffer = createBuffer(device, bytecount: self.bytecount, options: options, createWith: createWith)
            buffers.append(buffer)
        }
    }
    
    func createBuffer(device: MTLDevice, bytecount: Int, options: MTLResourceOptions) -> EncodableBuffer {
        let thisBuffer = BaseEncodableBuffer()
        thisBuffer.bytecount = self.bytecount
        thisBuffer.prepareBuffer(device, options: options)
        return thisBuffer
    }
    
    func createBuffer(device: MTLDevice, bytecount: Int, options: MTLResourceOptions, createWith: (Self) -> EncodableBuffer) -> EncodableBuffer {
        return createWith(self)
    }
    
    func getBuffer() -> EncodableBuffer {
        var buffer = buffers[buffersIndex]
        buffersIndex = (buffersIndex + 1) % buffersCount
        
        // return the buffer unmodified and let the user determine how to write to it
        return buffer
    }
    
    func getBuffer(bufferIndex: Int) -> EncodableBuffer {
        return buffers[bufferIndex]
    }
}

class BaseBufferPool: BufferPool {
    // init with max bytecount needed
    // - E.G. in case # of vertices needed changes
    var bytecount:Int
    var buffersCount:Int
    var buffersIndex:Int = 0
    internal var buffers: [EncodableBuffer] = []
    
    required init(device: MTLDevice, bytecount: Int, buffersCount: Int, options: MTLResourceOptions = .CPUCacheModeDefaultCache) {
        self.bytecount = bytecount
        self.buffersCount = buffersCount
    }
    
    //deinit {
        //TODO: release buffer memory?
    //}
}

class SingleBuffer: BufferPool {
    var bytecount:Int
    var buffersCount:Int
    var buffersIndex:Int = 0
    var buffersSemaphore:dispatch_semaphore_t?
    var buffers: [EncodableBuffer] = []
    
    required init(device:MTLDevice, bytecount:Int, buffersCount:Int = 1, options: MTLResourceOptions = .StorageModeShared) {
        self.bytecount = bytecount
        self.buffersCount = buffersCount
    }
    
    func getBuffer() -> EncodableBuffer {
        return buffers.first!
    }
    
}
