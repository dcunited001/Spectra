//
//  S3DXMLSpec.swift
//  Spectra
//
//  Created by David Conner on 10/17/15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import Foundation
import Spectra
import Ono
import Quick
import Nimble
import Metal

class S3DXMLSpec: QuickSpec {
    override func spec() {
        
        let device = MTLCreateSystemDefaultDevice()
        let library = device!.newDefaultLibrary()
        let testBundle = NSBundle(forClass: S3DXMLSpec.self)
        let xmlData: NSData = S3DXML.readXML(testBundle, filename: "S3DXMLTest")
        let xml = S3DXML(data: xmlData)
        
        var descriptorManager = SpectraDescriptorManager(library: library!)
        descriptorManager = xml.parse(descriptorManager)
        
        describe("SpectraDescriptorManager") {
            it("parses enumGroups from XSD") {
                let mtlStoreActionEnum = descriptorManager.mtlEnums["mtlSamplerAddressMode"]!
                expect(mtlStoreActionEnum.getValue("ClampToEdge")) == 0
            }
        }
        
//        describe("S3DXML") {
//            
//        }

        describe("S3DXMLMTLFunctionNode") {
            let vertName = "basic_color_vertex"
            let fragName = "basic_color_fragment"
            let compName = "test_compute_function"
            
            it("can parse render and compute functions") {
                let vert = descriptorManager.vertexFunctions[vertName]!
                expect(vert.name) == vertName
                let frag = descriptorManager.fragmentFunctions[fragName]!
                expect(frag.name) == fragName
                let comp = descriptorManager.computeFunctions["test_compute_function"]!
                expect(comp.name) == compName
            }
            
//            it("can parse from references") {
//                
//            }
        }

        describe("S3DXMLMTLVertexDescriptorNode") {
            it("can parse the attribute descriptor array") {
                let vertDesc = descriptorManager.vertexDescriptors["common_vertex_desc"]!
                expect(vertDesc.attributes[0].format) == MTLVertexFormat.Float4
                expect(vertDesc.attributes[1].offset) == 16
            }
            
            it("can parse the buffer layout descriptor array") {
                let vertDesc = descriptorManager.vertexDescriptors["common_vertex_desc"]!
                expect(vertDesc.layouts[0].stepFunction) == MTLVertexStepFunction.PerVertex
                expect(vertDesc.layouts[0].stride) == 48
                expect(vertDesc.layouts[0].stepRate) == 1
            }
            
//            it("can parse from references") {
//                let vertDesc = descriptorManager.vertexDescriptors["common_vertex_desc"]!
//            }
        }
        
        describe("S3DXMLMTLTextureDescriptorNode") {
            it("can parse a MTLVertexDescriptor") {
                let desc = descriptorManager.textureDescriptors["texture_desc"]!
                expect(desc.textureType) == MTLTextureType.Type3D
                expect(desc.pixelFormat) == MTLPixelFormat.RGBA32Float
                expect(desc.width) == 100
                expect(desc.height) == 100
                expect(desc.depth) == 100
                expect(desc.mipmapLevelCount) == 100
                expect(desc.sampleCount) == 100
                expect(desc.arrayLength) == 100
                // desc.resourceOptions
                expect(desc.cpuCacheMode) == MTLCPUCacheMode.WriteCombined
                expect(desc.storageMode) == MTLStorageMode.Shared
//                expect(desc.usage) == MTLTextureUsage.PixelFormatView
            }
            
//            it("can parse from references") {
//                
//            }
        }
        
        describe("S3DXMLMTLSamplerDescriptorNode") {
            it("can parse a sampler descriptor") {
                let desc = descriptorManager.samplerDescriptors["sampler_desc"]!
                expect(desc.minFilter) == MTLSamplerMinMagFilter.Linear
                expect(desc.magFilter) == MTLSamplerMinMagFilter.Linear
                expect(desc.mipFilter) == MTLSamplerMipFilter.Linear
                expect(desc.maxAnisotropy) == 10
                expect(desc.sAddressMode) == MTLSamplerAddressMode.Repeat
                expect(desc.tAddressMode) == MTLSamplerAddressMode.MirrorRepeat
                expect(desc.rAddressMode) == MTLSamplerAddressMode.ClampToZero
                expect(desc.normalizedCoordinates) == false
                expect(desc.lodMinClamp) == 1.0
                expect(desc.lodMaxClamp) == 10.0
                expect(desc.lodAverage) == true
                expect(desc.compareFunction) == MTLCompareFunction.Always
            }
        }
        
        describe("S3DXMLMTLStencilDescriptorNode") {
            it("can parse a stencil descriptor") {
                let desc = descriptorManager.stencilDescriptors["stencil_desc"]!
                expect(desc.stencilCompareFunction) == MTLCompareFunction.Never
                expect(desc.stencilFailureOperation) == MTLStencilOperation.Replace
                expect(desc.depthFailureOperation) == MTLStencilOperation.IncrementWrap
                expect(desc.depthStencilPassOperation) == MTLStencilOperation.DecrementWrap
            }
        }
        
        describe("S3DXMLMTLDepthStencilDescriptorNode") {
            it("can parse a depth stencil descriptor") {
                let desc = descriptorManager.depthStencilDescriptors["depth_stencil_desc"]!
                expect(desc.depthCompareFunction) == MTLCompareFunction.Never
                expect(desc.depthWriteEnabled) == true
                expect(desc.frontFaceStencil) == descriptorManager.stencilDescriptors["stencil_desc"]
                expect(desc.backFaceStencil) == descriptorManager.stencilDescriptors["stencil_desc"]
            }
        }
        
        describe("S3DXMLMTLRenderPipelineColorAttachmentDescriptorNode") {
            it("can parse a render pipeline color attachment descriptor") {
                let desc = descriptorManager.colorAttachmentDescriptors["color_attach_desc"]!
                expect(desc.blendingEnabled) == true
                expect(desc.sourceRGBBlendFactor) == MTLBlendFactor.Zero
                expect(desc.destinationRGBBlendFactor) == MTLBlendFactor.SourceColor
                expect(desc.rgbBlendOperation) == MTLBlendOperation.Subtract
                expect(desc.sourceAlphaBlendFactor) == MTLBlendFactor.BlendAlpha
                expect(desc.destinationAlphaBlendFactor) == MTLBlendFactor.OneMinusBlendAlpha
                expect(desc.alphaBlendOperation) == MTLBlendOperation.Max
                expect(desc.pixelFormat) == MTLPixelFormat.BGRA8Unorm
            }
        }
        
        describe("S3DXMLMTLRenderPipelineDescriptorNode") {
            it("can parse a render pipeline descriptor") {
                let desc = descriptorManager.renderPipelineDescriptors["render_pipeline_desc"]!
                expect(desc.label) == "render-pipeline-descriptor"
                expect(desc.sampleCount) == 2
                expect(desc.alphaToCoverageEnabled) == true
                expect(desc.alphaToOneEnabled) == true
                expect(desc.rasterizationEnabled) == true
                expect(desc.depthAttachmentPixelFormat) == MTLPixelFormat.Depth32Float
                expect(desc.stencilAttachmentPixelFormat) == MTLPixelFormat.Stencil8
                expect(desc.vertexFunction!.name) == "basic_color_vertex"
                expect(desc.fragmentFunction!.name) == "basic_color_fragment"
                expect(desc.vertexDescriptor) == descriptorManager.vertexDescriptors["common_vertex_desc"]!
                expect(desc.colorAttachments[0]) == descriptorManager.colorAttachmentDescriptors["color_attach_desc"]
            }
        }
        
        describe("S3DXMLMTLComputePipelineDescribeNode") {
            it("can parse a compute pipeline descriptor") {
                let desc = descriptorManager.computePipelineDescriptors["compute_pipeline_desc"]!
                expect(desc.label) == "compute-pipeline-descriptor"
                expect(desc.threadGroupSizeIsMultipleOfThreadExecutionWidth) == true
                expect(desc.computeFunction!.name) == "test_compute_function"
            }
        }
        
        describe("S3DXMLMTLRenderPassColorAttachmentDescriptorNode") {
            it("can parse a render pass color attachment descriptor") {
                let desc = descriptorManager.renderPassColorAttachmentDescriptors["rpass_color_attach_desc"]!
                expect(desc.level) == 1
                expect(desc.slice) == 1
                expect(desc.depthPlane) == 1
                expect(desc.resolveLevel) == 1
                expect(desc.resolveSlice) == 1
                expect(desc.resolveDepthPlane) == 1
                expect(desc.loadAction) == MTLLoadAction.Load
                expect(desc.storeAction) == MTLStoreAction.Store
                //clearColor
            }
        }
        
        describe("S3DXMLMTLRenderPassDepthAttachmentDescriptorNode") {
            it("can parse a render pass depth attachment descriptor") {
                let desc = descriptorManager.renderPassDepthAttachmentDescriptors["rpass_depth_attach_desc"]!
                expect(desc.level) == 1
                expect(desc.slice) == 1
                expect(desc.depthPlane) == 1
                expect(desc.resolveLevel) == 1
                expect(desc.resolveSlice) == 1
                expect(desc.resolveDepthPlane) == 1
                expect(desc.loadAction) == MTLLoadAction.Load
                expect(desc.storeAction) == MTLStoreAction.Store
                expect(desc.clearDepth) == 2.0
                expect(desc.depthResolveFilter) == MTLMultisampleDepthResolveFilter.Min
            }
        }
        
        describe("S3DXMLMTLRenderPassStencilAttachmentDescriptorNode") {
            it("can parse a render pass stencil attachment descriptor") {
                let desc = descriptorManager.renderPassStencilAttachmentDescriptors["rpass_stencil_attach_desc"]!
                expect(desc.level) == 1
                expect(desc.slice) == 1
                expect(desc.depthPlane) == 1
                expect(desc.resolveLevel) == 1
                expect(desc.resolveSlice) == 1
                expect(desc.resolveDepthPlane) == 1
                expect(desc.loadAction) == MTLLoadAction.Load
                expect(desc.storeAction) == MTLStoreAction.Store
                expect(desc.clearStencil) == 0
            }
        }
        
        describe("S3DXMLMTLRenderPassDescriptorNode") {
            it("can parse a render pass descriptor") {
                let desc = descriptorManager.renderPassDescriptors["render_pass_desc"]!
                let colorAttach = descriptorManager.renderPassColorAttachmentDescriptors["rpass_color_attach_desc"]!
                let depthAttach = descriptorManager.renderPassDepthAttachmentDescriptors["rpass_depth_attach_desc"]!
                let stencilAttach = descriptorManager.renderPassStencilAttachmentDescriptors["rpass_stencil_attach_desc"]!
                
                expect(desc.colorAttachments[0]) == colorAttach
                expect(desc.depthAttachment) == depthAttach
                expect(desc.stencilAttachment) == stencilAttach
            }
        }
        
    }
}