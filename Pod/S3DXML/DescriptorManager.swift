//
//  DescriptorManager.swift
//  Pods
//
//  Created by David Conner on 10/19/15.
//
//

import Foundation
import Metal
import Ono

public class SpectraDescriptorManager {
    public var library: MTLLibrary // TODO: support multiple libraries?
    
    public var xsd: S3DXSD
    public var mtlEnums: [String: S3DMtlEnum] = [:]
    public var vertexFunctions: [String: MTLFunction] = [:]
    public var fragmentFunctions: [String: MTLFunction] = [:]
    public var computeFunctions: [String: MTLFunction] = [:]
    
    public var vertexDescriptors: [String: MTLVertexDescriptor] = [:]
    public var textureDescriptors: [String: MTLTextureDescriptor] = [:]
    public var samplerDescriptors: [String: MTLSamplerDescriptor] = [:]
    public var stencilDescriptors: [String: MTLStencilDescriptor] = [:]
    public var depthStencilDescriptors: [String: MTLDepthStencilDescriptor] = [:]
    public var colorAttachmentDescriptors: [String: MTLRenderPipelineColorAttachmentDescriptor] = [:]
    public var renderPipelineDescriptors: [String: MTLRenderPipelineDescriptor] = [:]
    public var renderPassColorAttachmentDescriptors: [String: MTLRenderPassColorAttachmentDescriptor] = [:]
    public var renderPassDepthAttachmentDescriptors: [String: MTLRenderPassDepthAttachmentDescriptor] = [:]
    public var renderPassStencilAttachmentDescriptors: [String: MTLRenderPassStencilAttachmentDescriptor] = [:]
    public var renderPassDescriptors: [String: MTLRenderPassDescriptor] = [:]
    public var computePipelineDescriptors: [String: MTLComputePipelineDescriptor] = [:]
    
    public init(library: MTLLibrary) {
        self.library = library
        
        // just parsing enum types from XSD for now
        let xmlData = S3DXSD.readXSD("Spectra3D")
        xsd = S3DXSD(data: xmlData)
        xsd.parseEnumTypes()
        mtlEnums = xsd.enumTypes
    }
}