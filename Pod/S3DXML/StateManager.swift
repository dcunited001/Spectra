//
//  StateManager.swift
//  Pods
//
//  Created by David Conner on 10/19/15.
//
//

import Foundation
import Metal
import Ono

// TODO: remove 'spectra' from class
public class SpectraStateManager {
    
    // TODO: move pipeline generator functions here
    // TODO: pipeline generation functions with blocks for input
    
    public var renderPipelineStates: [String: MTLRenderPipelineState] = [:]
    public var computePipelineStates: [String: MTLComputePipelineState] = [:]
    public var depthStencilStates: [String: MTLDepthStencilState] = [:]
    public var samplerStates: [String: MTLSamplerState] = [:]
    
    public init() {
        
    }
}
