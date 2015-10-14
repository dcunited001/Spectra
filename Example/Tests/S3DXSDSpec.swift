//
//  S3DXSDTests.swift
//  Spectra
//
//  Created by David Conner on 10/14/15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

// https://github.com/Quick/Quick

import Spectra
import Ono
import Quick
import Nimble

class S3DXSDSpec: QuickSpec {
    override func spec() {
        let xmlData = S3DXSD.readXSD("Spectra3D")
        let xsd: ONOXMLDocument? = try! ONOXMLDocument(data: xmlData)
        
        describe("S3DAttributeGroup") {
            let refableName = "refable"
            let refableSelector = "xs:attributeGroup[name=\(refableName)]"
            var attrGroup: S3DAttributeGroup?
            
            beforeEach {
                let attrGroupElem = xsd!.firstChildWithCSS(refableSelector)
                attrGroup = S3DAttributeGroup(elem: attrGroupElem)
            }
            
            it("has a name") {
                expect(attrGroup!.name) == refableName
            }
            
            it("has attributes with name and type") {
                expect(attrGroup!.attributes["key"]!) == "xs:string"
                expect(attrGroup!.attributes["ref"]!) == "xs:string"
            }
        }
        
        describe("S3DMtlEnum") {
            let enumName = "mtlStepFunction"
            let enumSelector = "xs:simpleType[name=\(enumName)][mtl-enum=true]"
            var mtlEnum: S3DMtlEnum?
            
            beforeEach {
                let mtlEnumElem = xsd!.firstChildWithCSS(enumSelector)
                mtlEnum = S3DMtlEnum(elem: mtlEnumElem)
            }
            
            it("has a name") {
                expect(mtlEnum!.name) == enumName
            }
            
            it("has a map of enumerations") {
                expect(mtlEnum!.values["Constant"]!) == 0
                expect(mtlEnum!.values["PerInstance"]!) == 2
            }
        }
        
        describe("S3DMtlDescriptorType") {
            
        }
        
        describe("S3DMtlDescriptorElement") {
            
        }
    }
}

