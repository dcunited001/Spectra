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

let inflightBuffersCountDefault = 3 // three is magic number

// N.B. planning on always accessing Buffer via BufferProvider (and MTLBuffer via Buffer)
// - so that interface is consistent and so that stuff can easily be built on top of one thing

protocol BufferPool: class {
    var bytecount:Int { get set }
    var buffersCount:Int { get set }
    var buffersIndex:Int { get set }
    var buffersSemaphore:dispatch_semaphore_t? { get set }
    var buffers: [Buffer] { get set } // private
    
    // N.B. must deinit resources!
    
    init(device: MTLDevice, bytecount: Int, buffersCount: Int, options: MTLResourceOptions)
    func prepareBufferPool(device: MTLDevice, bytecount: Int, options: MTLResourceOptions)
    func prepareBufferPool(device: MTLDevice, bytecount: Int, options: MTLResourceOptions, createWith: (Self) -> Buffer)
    func createBuffer(device: MTLDevice, bytecount: Int, options: MTLResourceOptions) -> Buffer
    func createBuffer(device: MTLDevice, bytecount: Int, options: MTLResourceOptions, createWith: (Self) -> Buffer) -> Buffer
    func releaseBuffer(numBuffers:Int)
    
    func getBuffer() -> Buffer
}

extension BufferPool {
    //    var bytecount:Int
    //    var availableBuffersIndex:Int = 0
    //    var availableBuffersSemaphore:dispatch_semaphore_t?
    //    internal var buffers: [Buffer] = []
    //    private var inflightBuffersCount:Int
    
    func prepareBufferPool(device: MTLDevice, bytecount: Int, options: MTLResourceOptions = .CPUCacheModeDefaultCache) {
        buffersSemaphore = dispatch_semaphore_create(buffersCount)
        for _ in 0...buffersCount-1 {
            let buffer = createBuffer(device, bytecount: self.bytecount, options: options)
            buffers.append(buffer)
        }
    }
    
    func prepareBufferPool(device: MTLDevice, bytecount: Int, options: MTLResourceOptions = .CPUCacheModeDefaultCache, createWith: (Self) -> Buffer) {
        buffersSemaphore = dispatch_semaphore_create(buffersCount)
        for _ in 0...buffersCount-1 {
            let buffer = createBuffer(device, bytecount: self.bytecount, options: options, createWith: createWith)
            buffers.append(buffer)
        }
    }
    
    func releaseBuffer(numBuffers:Int) {
        for _ in 0...numBuffers-1 {
            dispatch_semaphore_signal(buffersSemaphore!)
        }
    }
    
    func getBuffer() -> Buffer {
        var buffer = buffers[buffersIndex]
        
        buffersIndex = (buffersIndex + 1) % buffersCount
        
        // return the buffer unmodified and let the user determine how to write to it
        return buffer
    }
    
    func createBuffer(device: MTLDevice, bytecount: Int, options: MTLResourceOptions) -> Buffer {
        let thisBuffer = BaseBuffer()
        thisBuffer.bytecount = self.bytecount
        thisBuffer.prepareBuffer(device, options: options)
        return thisBuffer
    }
    
    func createBuffer(device: MTLDevice, bytecount: Int, options: MTLResourceOptions, createWith: (Self) -> Buffer) -> Buffer {
        return createWith(self)
    }
}

class BaseBufferPool: BufferPool {
    // init with max bytecount needed
    // - E.G. in case # of vertices needed changes
    var bytecount:Int
    var buffersCount:Int
    var buffersIndex:Int = 0
    var buffersSemaphore:dispatch_semaphore_t?
    internal var buffers: [Buffer] = []
    
    required init(device: MTLDevice, bytecount: Int, buffersCount: Int = inflightBuffersCountDefault, options: MTLResourceOptions = .CPUCacheModeDefaultCache) {
        self.bytecount = bytecount
        self.buffersCount = buffersCount
    }
    
    deinit {
        releaseBuffer(buffersCount)
    }
}

class SingleBufferPool: BufferPool {
    var bytecount:Int
    var buffersCount:Int
    var buffersIndex:Int = 0
    var buffersSemaphore:dispatch_semaphore_t?
    var buffers: [Buffer] = []
    
    required init(device:MTLDevice, bytecount:Int, buffersCount:Int = 1, options: MTLResourceOptions = .StorageModeManaged) {
        self.bytecount = bytecount
        self.buffersCount = buffersCount
        prepareBuffer(device, options: options)
    }
    
    func prepareBuffer(device:MTLDevice, options:MTLResourceOptions) {
        let singleBuffer = BaseBuffer()
        singleBuffer.bytecount = bytecount
        singleBuffer.prepareBuffer(device, options: options)
        buffers = [singleBuffer]
    }
    
    func prepareBufferPool(device:MTLDevice, bytecount:Int, options:MTLResourceOptions) {
        
    }
    
    func prepareBufferPool(device:MTLDevice, bytecount:Int, options:MTLResourceOptions, createWith: (SingleBufferPool) -> Buffer) {
        
    }
    
    //    func createBuffer(device:MTLDevice, bytecount:Int, options:MTLResourceOptions) -> Buffer {
    //
    //    }
    //
    //    func createBuffer(device:MTLDevice, bytecount:Int, options:MTLResourceOptions, createWith: (SingleBufferProvider) -> Buffer) -> Buffer {
    //
    //    }
    
    func getBuffer() -> Buffer {
        return buffers.first!
    }
    
}



