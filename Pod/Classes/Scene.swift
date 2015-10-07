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


//TODO: explore using a state machine for RenderStrategy, where states are dynamically defined for each renderer type, a default state transition is defined which calls endEncoding() and creates a new renderEncoder and custom state transitions can be defined to transition renderEncoders without creating new ones
//TODO: exploring using a similar map for Update Objects, so top level controller can easily specify dynamic object behaviors without needing to subclass

class Scene: RenderDelegate, UpdateDelegate {
    var pipelineStateMap: [String:MTLRenderPipelineState] = [:]
    var rendererMap: [String:Renderer] = [:]
    var nodeMap: [String:[Node]] = [:]
    
    //    init() {
    //
    //    }
    
//    func setupRenderStrategy
    
    func renderObjects(drawable: CAMetalDrawable, renderPassDescriptor: MTLRenderPassDescriptor, commandBuffer: MTLCommandBuffer) {

        // pass commandBuffer & renderPassDescriptor to renderStrategy
        // - to create renderEncoder
    }
    
    func updateObjects(timeSinceLastUpdate: CFTimeInterval) {
        
    }
}
