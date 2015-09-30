//
//  SpectraCommandBufferProvider.swift
//  Spectra
//
//  Created by David Conner on 9/27/15.
//  Copyright © 2015 Spectra. All rights reserved.
//

//TODO: command buffer provider for compute functions? do i need to differentiate this?

import Metal

let inflightCommandBuffers: Int = 3;

class CommandBufferProvider {
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
        
        availableBuffersIndex = (availableBuffersIndex + 1) % inflightBuffersCount
        
        return buffer
    }
    
    deinit {
        for i in 0 ... self.inflightBuffersCount {
            // TODO: is this correct? this deinit's the same thing over and over
            // TODO: deinit memory for buffers?
            dispatch_semaphore_signal(self.availableBuffersSemaphore)
        }
    }
}
