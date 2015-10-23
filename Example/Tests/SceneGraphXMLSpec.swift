//
//  SceneGraphXMLSpec.swift
//  Spectra
//
//  Created by David Conner on 10/20/15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import Foundation
import Spectra
import Ono
import Quick
import Nimble
import Metal
import simd

class CustomView: Spectra.BaseWorldView {
    var customVar: String?
}

class CustomCamera: Spectra.BaseCamera {
    var customVar: String?
}

func compareFloat4(x:float4, to:float4) -> Bool {
    //no == ????
    //wow that's dumb. or maybe i'm dumb?
    return (x.x == to.x &&
        x.y == to.y &&
        x.z == to.z
        && x.w == to.w)
}

class SceneGraphXMLSpec: QuickSpec {
    
    override func spec() {
        let testBundle = NSBundle(forClass: S3DXMLSpec.self)
        let xmlData: NSData = SceneGraphXML.readXML(testBundle, filename: "SceneGraphXMLTest")
        let sceneGraphXML = SceneGraphXML(data: xmlData)
        
        var sceneGraph = SceneGraph()
        sceneGraph.registerViewMonad("custom") {
            let v = CustomView()
            v.customVar = "custom"
            return v
        }
        sceneGraph.registerCameraMonad("custom") {
            let c = CustomCamera()
            c.customVar = "custom"
            return c
        }
        sceneGraph = sceneGraphXML.parse(sceneGraph)
        
        let defaultUniformsPos = float4(0,0,1,1)
        let defaultUniformsRotation = float4(1,0,0,0)
        let defaultUniformsScale = float4(1,1,1,0)
        
        describe("SGXMLUniformsNode") {
            it("parses uniforms nodes") {
                let u = sceneGraph.views["world"]!.uniforms
                
                expect(compareFloat4(u.uniformPosition, to: defaultUniformsPos)).to(beTrue())
                expect(compareFloat4(u.uniformRotation, to: defaultUniformsRotation)).to(beTrue())
                expect(compareFloat4(u.uniformScale, to: defaultUniformsScale)).to(beTrue())
            }
        }
        
        describe("SGXMLViewNode") {
            it("parses default nodes") {
                let u = sceneGraph.views["world"]!.uniforms
                
                expect(compareFloat4(u.uniformPosition, to: defaultUniformsPos)).to(beTrue())
                expect(compareFloat4(u.uniformRotation, to: defaultUniformsRotation)).to(beTrue())
                expect(compareFloat4(u.uniformScale, to: defaultUniformsScale)).to(beTrue())
            }
            
            it("allows for custom implementations of Uniformable via viewMonads") {
                let customWorld = sceneGraph.views["customWorld"] as! CustomView
                expect(customWorld.customVar) == "custom"
            }
        }
        
        describe("SGXMLCameraNode") {
            let camEye = float4(0,0,1,1)
            let camCenter = float4(0,0,0,1)
            let camUp = float4(0,1,0,0)
            
            it("parses default nodes") {
                let cam = sceneGraph.cameras["default"]!
                expect(compareFloat4(cam.camEye, to: camEye)).to(beTrue())
                expect(compareFloat4(cam.camCenter, to: camCenter)).to(beTrue())
                expect(compareFloat4(cam.camUp, to: camUp)).to(beTrue())
            }
            
            it("allows for custom implementations of Uniformable via viewMonads") {
                let customCam = sceneGraph.cameras["customCamera"] as! CustomCamera
                expect(customCam.customVar) == "custom"
            }
        }
        
        describe("SGXMLPerspectiveNode") {
            let fov:Float = 65.0
            let angle:Float = 35.0
            let aspect:Float = 1.0
            let near:Float = 0.01
            let far:Float = 100.0
            
            let pers = sceneGraph.perspectives["landscape"]!
            
            it("parses perspective with fov") {
                expect(pers.perspectiveType) == "fov"
                expect(pers.perspectiveArgs["fov"]!) == fov
                expect(pers.perspectiveArgs["angle"]!) == angle
                expect(pers.perspectiveArgs["aspect"]!) == aspect
                expect(pers.perspectiveArgs["near"]!) == near
                expect(pers.perspectiveArgs["far"]!) == far
            }
        }
        
        describe("SGXMLMeshGeneratorNode") {
            let customArgs = ["rowCount": 10, "colCount": 10]
            let cubeGen = sceneGraph.meshGenerators["cubeGen"]! as! CubeGenerator
            let latticeGen = sceneGraph.meshGenerators["latticeGen"]! as! TriangularQuadLatticeGenerator
            
            it("parses meshes without args") {
                expect(cubeGen.getVertices().count) == 8
            }
            
            it("passes args to mesh generator monad for custom generator types") {
                expect(latticeGen.rowCount) == 100
                expect(latticeGen.colCount) == 100
//                expect(latticeGen.getVertices().count) == 0
//                expect(latticeGen.getVertices().count) == 121
            }
        }
        
        describe("SGXMLMeshNode") {
            
        }
    }
    
}
