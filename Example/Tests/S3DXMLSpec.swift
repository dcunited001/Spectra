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

        //TODO: still need to test these, as they need to create real functions
//        describe("S3DXMLMTLFunctionNode") {
//            it("can parse a MTLFunction") {
//                
//            }
//            
//            it("can parse from references") {
//                
//            }
//        }

        describe("S3DXMLMTLVertexDescriptorNode") {
            it("can parse the attribute descriptor array") {
                let vertDesc = descriptorManager.vertexDescriptors["common_vertex_descriptor"]!
                expect(vertDesc.attributes[0].format) == MTLVertexFormat.Float4
                expect(vertDesc.attributes[1].offset) == 16
            }
            
            it("can parse the buffer layout descriptor array") {
                let vertDesc = descriptorManager.vertexDescriptors["common_vertex_descriptor"]!
                expect(vertDesc.layouts[0].stepFunction) == MTLVertexStepFunction.PerVertex
                expect(vertDesc.layouts[0].stride) == 48
                expect(vertDesc.layouts[0].stepRate) == 1
            }
            
            it("can parse from references") {
                let vertDesc = descriptorManager.vertexDescriptors["common_vertex_descriptor"]!
            }
        }
        
//        describe("MTLTextureDescriptorNode") {
//            it("can parse a MTLVertexDescriptor") {
//                
//            }
//            
//            it("can parse from references") {
//                
//            }
//        }
        
        describe("S3DXMLMtlSamplerDescriptorNode") {
            it("can parse a sampler descriptor") {
                let desc = descriptorManager.samplerDescriptors["sampler_desc"]!
                expect(desc.minFilter) == MTLSamplerMinMagFilter.Linear
                expect(desc.magFilter) == MTLSamplerMinMagFilter.Linear
                expect(desc.mipFilter) == MTLSamplerMipFilter.Linear
                expect(desc.maxAnisotropy) == 10
                expect(desc.sAddressMode) == MTLSamplerAddressMode.ClampToZero
                expect(desc.tAddressMode) == MTLSamplerAddressMode.ClampToZero
                expect(desc.rAddressMode) == MTLSamplerAddressMode.ClampToZero
                expect(desc.normalizedCoordinates) == false
                expect(desc.lodMinClamp) == 1.0
                expect(desc.lodMaxClamp) == 10.0
                expect(desc.lodAverage) == true
                expect(desc.compareFunction) == MTLCompareFunction.Always
            }
        }
        
        describe("S3DXMLMtlStencilDescriptorNode") {
            it("can parse a stencil descriptor") {
                let desc = descriptorManager.stencilDescriptors["stencil_desc"]!
                expect(desc.stencilCompareFunction) == MTLCompareFunction.Never
                expect(desc.stencilFailureOperation) == MTLStencilOperation.Zero
                expect(desc.depthFailureOperation) == MTLStencilOperation.Zero
                expect(desc.depthStencilPassOperation) == MTLStencilOperation.Zero
            }
        }
        
        describe("S3DXMLMtlDepthStencilDescriptorNode") {
            it("can parse a depth stencil descriptor") {
                let desc = descriptorManager.depthStencilDescriptors["depth_stencil_desc"]!
                expect(desc.depthCompareFunction) == MTLCompareFunction.Never
                expect(desc.depthWriteEnabled) == true
            }
        }
        
//        describe("S3DXMLMTLColorAttachmentDescriptorNode") {
//            
//        }
//        
//        mtlRenderPipelineDescriptor
//        mtlRenderPassColorAttachmentDescriptor
//        mtlRenderPassDepthAttachmentDescriptor
//        mtlRenderPassStencilAttachmentDescriptor
//        mtlRenderPassDescriptor
        
//        describe("S3DXMLMTLComputePipelineDescriptorNode") {
//            it("can parse a compute pipeline descriptor") {
//                //TODO: include compute function for tests
//            }
//        }
        
    }
}