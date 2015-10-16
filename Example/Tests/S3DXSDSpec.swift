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
        
        describe("S3DMtlDescriptorElement") {
            //TODO: parse top-level elements with type next
            // - these are really just maps to the descriptor types
        }
        
        describe("S3DMtlDescriptorType") {
            //TODO: first lazily load all top-level types into a map
            // - then load each in order, deleting from the toLoad map when each is defined
            // - when loading currently unsatisfied dependencies, then skip to loading that next type
            // - this should account for most of the xsd parsing that i will deal with
        }
    }
}



//        describe("these will fail") {
//
//            it("can do maths") {
//                expect(1) == 2
//            }
//
//            it("can read") {
//                expect("number") == "string"
//            }
//
//            it("will eventually fail") {
//                expect("time").toEventually( equal("done") )
//            }
//
//            context("these will pass") {
//
//                it("can do maths") {
//                    expect(23) == 23
//                }
//
//                it("can read") {
//                    expect("🐮") == "🐮"
//                }
//
//                it("will eventually pass") {
//                    var time = "passing"
//
//                    dispatch_async(dispatch_get_main_queue()) {
//                        time = "done"
//                    }
//
//                    waitUntil { done in
//                        NSThread.sleepForTimeInterval(0.5)
//                        expect(time) == "done"
//
//                        done()
//                    }
//                }
//            }
//        }

