//
//  CubeViewController.swift
//  Spectra
//
//  Created by David Conner on 10/8/15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import UIKit
import MetalKit
import Spectra
import simd
import SWXMLHash

class CubeViewController: MetalViewController {
    
    @IBOutlet weak var spectraView: Spectra.BaseView! //TODO: weak?
    var scene: Spectra.Scene?
    var descMan: Spectra.SpectraDescriptorManager!
    var stateMan: Spectra.SpectraStateManager!
    
    let cubeKey = "spectra_cube"
    var pipelineStateMap: Spectra.RenderPipelineStateMap = [:]
    var encodableDataMap: Spectra.SceneEncodableDataMap = [:]
    var cubeGenerator: Spectra.CubeGenerator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stateMan = Spectra.SpectraStateManager()
        loadDescriptorManager()
        loadRenderPipelineStates()
        
        cubeGenerator = Spectra.CubeGenerator()
        
        scene = Spectra.Scene()
        setupPerspective()
        setupSceneGraph()
        setupNodeGeneratorMap()
        setupNodeMap()
        setupObjects()
        setupScene()
    }
    
    func loadDescriptorManager() {
        let bundle = NSBundle(forClass: CubeViewController.self)
        let xmlData: NSData = S3DXML.readXML(bundle, filename: "Spectra3D")
        let xml = S3DXML(data: xmlData)
        
        descMan = Spectra.SpectraDescriptorManager(library: spectraView.defaultLibrary)
        descMan = xml.parse(descMan)
    }
    
    // add descriptorConfigBlock?
    func loadRenderPipelineStates() {
        let pipeGen = RenderPipelineGenerator(library: spectraView.defaultLibrary)
        stateMan.renderPipelineStates = descMan.renderPipelineDescriptors.reduce(Spectra.RenderPipelineStateMap()) { (var hash, kv) in
            let k = kv.0
            var desc = kv.1.copy() as! MTLRenderPipelineDescriptor
            desc.colorAttachments[0].pixelFormat = .BGRA8Unorm
            let state = pipeGen.generateFromDescriptor(spectraView.device!, pipelineStateDescriptor: desc)
            hash[k] = state!
            return hash
        }
    }
    
    func setupPerspective() {
        //create encodable inputs for camera/etc
    }
    
    func setupSceneGraph() {
//        let bundle = NSBundle(forClass: CubeViewController.self)
//        let path = bundle.pathForResource("Cube", ofType: "xml")
//        let data = NSData(contentsOfFile: path!)
//        let sceneGraph = SceneGraph(xmlData: data!)
        let sceneGraph = SceneGraph()
        scene!.sceneGraph = sceneGraph
    }
    
    func setupNodeGeneratorMap() {
        scene!.nodeGeneratorMap["cube"] = Spectra.CubeGenerator()
    }
    
    func setupNodeMap() {
//        scene!.sceneGraph!.createGeneratedNodes(scene!.nodeGeneratorMap, nodeMap: scene!.nodeMap)
//        scene!.sceneGraph!.createRefNodes(scene!.nodeMap)
    }
    
    func setupObjects() {
// parse Cube.XML
//        let cubeXml = try! xml["root"]["mesh"].withAttr("id", cubeKey)
//        setupCube(cubeKey, xml: cubeXml)
    }
    
    func setupScene() {
        scene!.pipelineStateMap = pipelineStateMap
        
        // renderer strategy
        // updater strategy
    }
}

//    static let renderFunctionMap: Spectra.RenderPipelineFunctionMap = [
//        "basic": ("basicColorVertex", "basicColorFragment"),
//        "colorShift": ("basicColorShiftedVertex", "basicColorFragment"),
//        "colorShiftContinuous": ("basicColorShiftedContinuousVertex", "basicColorFragment")
//    ]

//    func loadPipelineStateMap() {
//        let pipelineGenerator = Spectra.RenderPipelineGenerator(library: spectraView.defaultLibrary)
//        pipelineStateMap = pipelineGenerator.generatePipelineMap(spectraView.device!, functionMap: CubeViewController.renderFunctionMap, setupDescriptor: { (desc) in
//            desc.colorAttachments[0].pixelFormat = .BGRA8Unorm
//            desc.vertexDescriptor = self.vertexDescriptorMap["common"]
//            return desc
//        })
//    }