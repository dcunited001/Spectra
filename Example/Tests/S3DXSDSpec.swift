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

class TableOfContentsSpec: QuickSpec {
    override func spec() {
        let xmlData = S3DXSD.readXSD("Spectra3D")
        let xsd: ONOXMLDocument? = try! ONOXMLDocument(data: xmlData)
        
        describe("S3DAttributeGroup") {
            
            
        }
        
        
        describe("these will fail") {
            
            it("can do maths") {
                expect(1) == 2
            }
            
            it("can read") {
                expect("number") == "string"
            }
            
            it("will eventually fail") {
                expect("time").toEventually( equal("done") )
            }
            
            context("these will pass") {
                
                it("can do maths") {
                    expect(23) == 23
                }
                
                it("can read") {
                    expect("🐮") == "🐮"
                }
                
                it("will eventually pass") {
                    var time = "passing"
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        time = "done"
                    }
                    
                    waitUntil { done in
                        NSThread.sleepForTimeInterval(0.5)
                        expect(time) == "done"
                        
                        done()
                    }
                }
            }
        }
    }
}

