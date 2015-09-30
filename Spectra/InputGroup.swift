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
// - except provide base classes to customize buffers for various situations, 
// - while providing common interface to BufferProvider

protocol InputGroup {
    //TODO: brainstorm 
    func prepareGroup(device: MTLDevice, options: MTLResourceOptions)
    func writeComputeGroup(encoder: MTLComputeCommandEncoder, options: [String:BufferOptions])
    func writeVertexGroup(encoder: MTLRenderCommandEncoder, options: [String:BufferOptions])
    func writeFragmentGroup(encoder: MTLRenderCommandEncoder, options: [String:BufferOptions])
    
    // this doesn't allow me to recombine buffers/inputs as needed.  or select specific ones.
    
    // how to init buffer providers?  
    // - either init outside and pass in buffers to functions
    // - or init providers inside and input group manages buffer pool access
    //   - but this makes semaphore access a bit difficult to manage flow control
    //   - and this makes it difficult to share buffers between different functions in a single pass
}

struct BufferOptions {
    var index:Int
    var offset:Int?
}