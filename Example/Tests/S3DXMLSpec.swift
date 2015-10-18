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
//        describe("MTLFunction") {
//            it("can parse a MTLFunction") {
//                
//            }
//            
//            it("can parse from references") {
//                
//            }
//        }

        describe("MTLVertexDescriptor") {
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
        
//        describe("MTLTextureDescriptor") {
//            it("can parse a MTLVertexDescriptor") {
//                
//            }
//            
//            it("can parse from references") {
//                
//            }
//        }
        
        
    }
}