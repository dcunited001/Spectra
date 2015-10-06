//
//  SpectraScene.swift
//  Spectra
//
//  Created by David Conner on 9/29/15.
//  Copyright © 2015 Spectra. All rights reserved.
//

import Metal

// SpectraScene
// - render is called
// - sets up render pass descriptor
// - mutating state between renderers in the collection
// - passes renderEncoder into encode(renderEncoder) for each renderer

class Scene { // ViewDelegate
    var renderers: [Renderer] = []
    
    //    init() {
    //
    //    }
    
    
//    func setupRenderStrategy
    
    func renderObjects(drawable: CAMetalDrawable, renderPassDescriptor: MTLRenderPassDescriptor, commandBuffer: MTLCommandBuffer) {

        // pass commandBuffer & renderPassDescriptor to renderStrategy
        // - to create renderEncoder
    }
    
}
