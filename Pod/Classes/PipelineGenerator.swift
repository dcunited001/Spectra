//
//  RenderPipelineGenerator.swift
//  Pods
//
//  Created by David Conner on 10/3/15.
//
//

import Metal

//TODO: RenderPipelineMap ... or just [String:MTLRenderPipelineState]
//TODO: ComputePipelineMap
//TODO: DepthStencilStateMap

//TODO: generators for DepthStencilState & SamplerState

public typealias RenderPipelineDescriptorSetupBlock = ((inout MTLRenderPipelineDescriptor) -> Void)

public class RenderPipelineGenerator {
    var library: MTLLibrary
    var vertexFunction: String
    var fragmentFunction: String
    
    init(library: MTLLibrary, vertexFunction: String, fragmentFunction: String) {
        self.library = library
        self.vertexFunction = vertexFunction
        self.fragmentFunction = fragmentFunction
    }
    
    //remove optional return and instead throw errors on program/pipeline load failures
    func generate(device: MTLDevice, setupDescriptor: ((inout MTLRenderPipelineDescriptor) -> Void)? = nil) -> MTLRenderPipelineState? {
        guard let vertexProgram = library.newFunctionWithName(vertexFunction) else {
            print("Couldn't load \(vertexFunction)")
            return nil
        }
        
        guard let fragmentProgram = library.newFunctionWithName(fragmentFunction) else {
            print("Couldn't load \(fragmentFunction)")
            return nil
        }
        
        var pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        
        setupDescriptor?(&pipelineStateDescriptor)
        var pipelineState: MTLRenderPipelineState?
        
        do {
            try pipelineState = (device.newRenderPipelineStateWithDescriptor(pipelineStateDescriptor))
        } catch(let err) {
            print("Failed to create pipeline state, error: \(err)")
            return nil
        }
        
        return pipelineState!
    }
}

public class ComputePipelineGenerator {
    var library: MTLLibrary
    var computeFunction: String
    
    init(library: MTLLibrary, computeFunction: String) {
        self.library = library
        self.computeFunction = computeFunction
    }
    
    //remove optional return and instead throw errors on program/pipeline load failures
    func generate(device:MTLDevice) -> MTLComputePipelineState? {
        guard let computeProgram = library.newFunctionWithName(computeFunction) else {
            print("Couldn't load \(computeFunction)")
            return nil
        }
        
        // pipelineStateDescriptor really doesn't do much for compute functions
//        var pipelineStateDescriptor = MTLComputePipelineDescriptor()
//        pipelineStateDescriptor.computeFunction = computeProgram
//        setupDescriptor?(&pipelineStateDescriptor)
        var pipelineState: MTLComputePipelineState?
        
        do {
            try pipelineState = device.newComputePipelineStateWithFunction(computeProgram)
        } catch(let err) {
            print("Failed to create pipeline state, error: \(err)")
            return nil
        }
        
        return pipelineState!
    }
}
