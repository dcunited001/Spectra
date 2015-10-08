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
    public var library: MTLLibrary
    
    public init(library: MTLLibrary) {
        self.library = library
    }
    
    public func generateDescriptor(device: MTLDevice, vertexFunction: String, fragmentFunction: String) -> MTLRenderPipelineDescriptor? {
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
        
        return pipelineStateDescriptor
    }
    
    public func generate(device: MTLDevice, vertexFunction: String, fragmentFunction: String, setupDescriptor: RenderPipelineDescriptorSetupBlock? = nil) -> MTLRenderPipelineState? {
        var pipelineStateDescriptor = generateDescriptor(device, vertexFunction: vertexFunction, fragmentFunction: fragmentFunction)
        
        setupDescriptor?(&pipelineStateDescriptor!)
        return generateFromDescriptor(device, pipelineStateDescriptor: pipelineStateDescriptor!)
    }
    
    public func generateFromDescriptor(device: MTLDevice, pipelineStateDescriptor: MTLRenderPipelineDescriptor) -> MTLRenderPipelineState? {
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
    public var library: MTLLibrary
    public var computeFunction: String
    
    init(library: MTLLibrary, computeFunction: String) {
        self.library = library
        self.computeFunction = computeFunction
    }
    
    //remove optional return and instead throw errors on program/pipeline load failures
    public func generate(device:MTLDevice) -> MTLComputePipelineState? {
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
