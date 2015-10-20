//
//  SpectraScene.swift
//  Spectra
//
//  Created by David Conner on 9/29/15.
//  Copyright © 2015 Spectra. All rights reserved.
//

import Metal
import simd

// SpectraScene
// - render is called
// - sets up render pass descriptor
// - mutating state between renderers in the collection
// - passes renderEncoder into encode(renderEncoder) for each renderer

//TODO: explore using a state machine for RenderStrategy, where states are dynamically defined for each renderer type, a default state transition is defined which calls endEncoding() and creates a new renderEncoder and custom state transitions can be defined to transition renderEncoders without creating new ones
//TODO: exploring using a similar map for Update Objects, so top level controller can easily specify dynamic object behaviors without needing to subclass

//use enums descending from String for id's!
public typealias RendererMap = [String:Renderer]
public typealias RenderPipelineStateMap = [String:MTLRenderPipelineState]
public typealias RenderPipelineDescriptorMap = [String:MTLRenderPipelineDescriptor]
public typealias DepthStencilStateMap = [String:MTLDepthStencilState]
public typealias DepthStencilDescriptorMap = [String:MTLDepthStencilDescriptor]
public typealias ComputePipelineStateMap = [String:MTLComputePipelineState]

public typealias VertexDescriptorMap = [String:MTLVertexDescriptor]

public class Scene: RenderDelegate, UpdateDelegate {
    public var pipelineStateMap: RenderPipelineStateMap = [:]
    public var depthStencilStateMap: DepthStencilStateMap = [:]
    public var rendererMap: RendererMap = [:]
    public var nodeMap: SceneNodeMap = [:]
    public var sceneGraph: SceneGraph?
    
    public var activeCamera: Camable = BaseCamera()
    public var worldUniforms: Uniformable = BaseUniforms()
    public var mvpInput: BaseEncodableInput<float4x4>?
    
    public init() {
        updateMvp()
    }

//    func setupRenderStrategy
    
    // for RenderStrategy, need to be able to:
    // - specify the objects to render
    // - acquire or create a renderEncoder
    // - pass in objects & renderEncoder to an encode block for the renderer
    
    public func renderObjects(drawable: CAMetalDrawable, renderPassDescriptor: MTLRenderPassDescriptor, commandBuffer: MTLCommandBuffer, inflightResourcesIndex: Int) {

        // pass commandBuffer & renderPassDescriptor to renderStrategy
        // - to create renderEncoder
    }
    
    public func updateObjects(timeSinceLastUpdate: CFTimeInterval, inflightResourcesIndex: Int) {
        
    }
}

extension Scene: HasMVPInput {
    public func calcMvp() -> float4x4 {
        return float4x4()
        //        return calcPerspectiveMatrix() * calcProjectionMatrix() * calcUniformMatrix()
    }
}
