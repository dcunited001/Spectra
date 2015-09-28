//
//  SpectraCommandBufferProvider.swift
//  Spectra
//
//  Created by David Conner on 9/27/15.
//  Copyright © 2015 Spectra. All rights reserved.
//

//TODO: command buffer provider for compute functions? do i need to differentiate this?
//TODO: buffer providers for input to render/compute functions
// - reusing a pool of these buffers should greatly increase performance
// - but locks us down to a particular size of buffer ... or does it??
// - if you just instantiate the largest buffer you'll need, then no.
// - however, it does make it more difficult to specialize the behavior you need 
//   for the buffer's memory (StorageModeShared, posix_memalign, etc.)
// - and thus, it makes it more difficult to develop rendering behavior, as your
//   nodes need to be aware of the implementation you're using

//import Foundation
import Metal

let inflightCommandBuffers: Int = 3;

class SpectraRenderCommandBufferProvider {
    var availableBuffersIndex:Int = 0
    var availableBuffersSemaphore:dispatch_semaphore_t
    var inflightBuffersCount:Int
    private var commandBuffers: [MTLCommandBuffer] = []
    
    init(commandQueue: MTLCommandQueue, numInflightBuffers:Int = inflightCommandBuffers) {
        inflightBuffersCount = numInflightBuffers
        availableBuffersSemaphore = dispatch_semaphore_create(inflightBuffersCount)
        
        for i in 0...inflightBuffersCount-1 {
            commandBuffers.append(commandQueue.commandBuffer())
        }
    }
    
    func nextCommandBuffer() -> MTLCommandBuffer {
        var buffer = commandBuffers[availableBuffersIndex]
        
        availableBuffersIndex++
        if availableBuffersIndex == inflightBuffersCount {
            availableBuffersIndex = 0
        }
        
        return buffer
    }
    
    deinit {
        for i in 0 ... self.inflightBuffersCount {
            dispatch_semaphore_signal(self.availableBuffersSemaphore)
        }
    }
}




