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

protocol BufferProvider {
    var bytecount:Int { get set }
    var availableBuffersIndex:Int { get set }
    var availableBuffersSemaphore:dispatch_semaphore_t? { get set }
    var buffers: [Buffer] { get set } // private
    
    init(device:MTLDevice, bytecount:Int, numInflightBuffers:Int, options:MTLResourceOptions)
    // deinit N.B. must deinit!
    
    func getBuffer() -> Buffer
}

class BufferPoolProvider: BufferProvider {
    // init with max bytecount needed
    // - E.G. in case # of vertices needed changes
    var bytecount:Int
    var availableBuffersIndex:Int = 0
    var availableBuffersSemaphore:dispatch_semaphore_t?
    var buffers: [Buffer] = []
    var inflightBuffersCount:Int
    
    required init(device: MTLDevice, bytecount: Int, numInflightBuffers: Int = inflightBuffersCountDefault, options: MTLResourceOptions = .CPUCacheModeDefaultCache) {
        self.bytecount = bytecount
        inflightBuffersCount = numInflightBuffers
        availableBuffersSemaphore = dispatch_semaphore_create(inflightBuffersCount)
        
        for i in 0...inflightBuffersCount-1 {
            let thisBuffer = BaseBuffer()
            thisBuffer.bytecount = self.bytecount
            thisBuffer.prepareBuffer(device, options: options)
            buffers.append(thisBuffer)
        }
    }
    
    deinit {
        for i in 0...inflightBuffersCount-1 {
            // TODO: is this correct? this deinit's the same thing over and over
            // TODO: dealloc command buffers?
            dispatch_semaphore_signal(self.availableBuffersSemaphore!)
        }
    }
    
    func getBuffer() -> Buffer {
        var buffer = buffers[availableBuffersIndex]
        
        availableBuffersIndex = (availableBuffersIndex + 1) % inflightBuffersCount
        
        // return the buffer unmodified and let the user determine how to write to it
        return buffer
    }
}

class SingleBufferProvider: BufferProvider {
    var bytecount:Int
    var availableBuffersIndex:Int = 0
    var availableBuffersSemaphore:dispatch_semaphore_t?
    var buffers: [Buffer] = []
    var inflightBuffersCount:Int
    
    required init(device:MTLDevice, bytecount:Int, numInflightBuffers:Int = 1, options: MTLResourceOptions = .StorageModeManaged) {
        self.bytecount = bytecount
        inflightBuffersCount = numInflightBuffer
        prepareBuffer(device, options: options)
    }
    
    func prepareBuffer(device:MTLDevice, options:MTLResourceOptions) {
        let singleBuffer = BaseBuffer()
        singleBuffer.bytecount = bytecount
        singleBuffer.prepareBuffer(device, options: options)
        buffers = [singleBuffer]
    }
    
    func getBuffer() -> Buffer {
        return buffers.first!
    }
    
}

