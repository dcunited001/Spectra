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
        let xmlData: NSData?
        
        let descriptorManager = SpectraDescriptorManager(library: library!)
        
        describe("SpectraDescriptorManager") {
            it("parses enumGroups from XSD") {  expect(descriptorManager.mtlEnums["mtlStoreAction"]!.getValue("ClampToEdge")) == 1
            }
        }
        
//        describe("S3DXML") {
//            
//        }
  
        describe("MTLFunction") {
            it("can parse a MTLFunction") {
                
            }
        }

        describe("MTLVertexDescriptor") {
            
            it("can parse a MTLVertexDescriptor") {
                
            }
        }
    }
}