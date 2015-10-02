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

class CommandBufferPool {
    var buffersIndex:Int = 0
    var buffersSemaphore:dispatch_semaphore_t
    var buffersCount:Int
    private var commandBuffers: [MTLCommandBuffer] = []
    
    init(commandQueue: MTLCommandQueue, buffersCount: Int = inflightCommandBuffers) {
        self.buffersCount = buffersCount
        buffersSemaphore = dispatch_semaphore_create(buffersCount)
        
        for i in 0...buffersCount - 1 {
            commandBuffers.append(commandQueue.commandBuffer())
        }
    }
    
    func nextCommandBuffer() -> MTLCommandBuffer {
        var buffer = commandBuffers[buffersIndex]
        
        buffer.addCompletedHandler { (buffer) in
            dispatch_semaphore_signal(self.buffersSemaphore)
        }
        buffersIndex = (buffersIndex + 1) % buffersCount
        
        return buffer
    }
    
    deinit {
        for i in 0 ... self.buffersCount {
            // TODO: is this correct? this deinit's the same thing over and over
            // TODO: deinit memory for buffers?
            dispatch_semaphore_signal(self.buffersSemaphore)
        }
    }
}
