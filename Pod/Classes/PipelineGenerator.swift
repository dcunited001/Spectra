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

public typealias RenderPipelineDescriptorSetupBlock = ((MTLRenderPipelineDescriptor) -> MTLRenderPipelineDescriptor)
public typealias RenderPipelineFunctionMap = [String:(String,String)]

public class RenderPipelineGenerator {
    public var library: MTLLibrary
    
    public init(library: MTLLibrary) {
        self.library = library
    }
    
    public func generateDescriptor(vertexFunction: String, fragmentFunction: String, setupDescriptor: RenderPipelineDescriptorSetupBlock? = nil) -> MTLRenderPipelineDescriptor? {
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
        pipelineStateDescriptor = setupDescriptor?(pipelineStateDescriptor) ?? setupDefaultDescriptor(pipelineStateDescriptor)
        return pipelineStateDescriptor
    }
    
    public func generateDescriptorMap(functionMap: RenderPipelineFunctionMap, setupDescriptor: RenderPipelineDescriptorSetupBlock? = nil) -> RenderPipelineDescriptorMap {
        return functionMap.reduce(RenderPipelineDescriptorMap()) { (var hash, kv) in
            let key = kv.0
            let tuple = kv.1 // i wish reduce had nested tuple syntax or destructuring
            hash[key] = self.generateDescriptor(tuple.0, fragmentFunction: tuple.1, setupDescriptor: setupDescriptor)
            return hash
        }
    }
    
    public func generatePipelineMap(device: MTLDevice, functionMap: RenderPipelineFunctionMap, setupDescriptor: RenderPipelineDescriptorSetupBlock? = nil) -> RenderPipelineStateMap {
        let descriptorMap = generateDescriptorMap(functionMap, setupDescriptor: setupDescriptor)
        
        return descriptorMap.reduce(RenderPipelineStateMap()) { (var hash, kv) in
            let key = kv.0
            let descriptor = kv.1
            hash[key] = self.generateFromDescriptor(device, pipelineStateDescriptor: descriptor)
            return hash
        }
    }
    
    public func generate(device: MTLDevice, vertexFunction: String, fragmentFunction: String, setupDescriptor: RenderPipelineDescriptorSetupBlock? = nil) -> MTLRenderPipelineState? {
        var pipelineStateDescriptor = generateDescriptor(vertexFunction, fragmentFunction: fragmentFunction, setupDescriptor: setupDescriptor)
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
    
    private func setupDefaultDescriptor(descriptor: MTLRenderPipelineDescriptor) -> MTLRenderPipelineDescriptor {
        descriptor.colorAttachments[0].pixelFormat = .BGRA8Unorm
        return descriptor
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
