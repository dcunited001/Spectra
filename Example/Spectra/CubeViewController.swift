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
    
    // i wish i could more strongly constrain the keys for these maps
    // - but i can't create a protocol for enums 
    // - AND type constraints apply to function params, regardless of whether those types are functionally equivalent
    // - ... womp, womp
//    enum CubePipelineKey: String {
//        case Basic = "basic"
//        case ColorShift = "colorShift"
//        case ColorShiftContinuous = "colorShiftContinuous"
//    }
    
    var pipelineStateMap: Spectra.RenderPipelineStateMap = [:]
    static let renderFunctionMap: Spectra.RenderPipelineFunctionMap = [
        "basic": ("basicColorVertex", "basicColorFragment"),
        "colorShift": ("basicColorShiftedVertex", "basicColorFragment"),
        "colorShiftContinuous": ("basicColorShiftedContinuousVertex", "basicColorFragment")
    ]
    
    var depthStencilStateMap: Spectra.DepthStencilStateMap = [:]
    var vertexDescriptorMap: Spectra.VertexDescriptorMap = [:]
    let cubeKey = "spectra_cube"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadVertexDescriptorMap()
        loadPipelineStateMap()
        loadDepthStencilMap()
        
        scene = Spectra.Scene()
        setupObjects()
        setupScene()
    }
    
    func loadVertexDescriptorMap() {
        vertexDescriptorMap["commonVertex"] = VertexDescriptorGenerator.commonVertexDescriptor()
    }
    
    func loadPipelineStateMap() {
        let pipelineGenerator = Spectra.RenderPipelineGenerator(library: spectraView.defaultLibrary)
        pipelineStateMap = pipelineGenerator.generatePipelineMap(spectraView.device!, functionMap: CubeViewController.renderFunctionMap, setupDescriptor: { (desc) in
            desc.colorAttachments[0].pixelFormat = .BGRA8Unorm
            desc.vertexDescriptor = self.vertexDescriptorMap["commonVertex"]
        })
    }
    
    func loadDepthStencilMap() {
        let depthStateDesc = MTLDepthStencilDescriptor()
        depthStateDesc.depthCompareFunction = .Always
        depthStateDesc.depthWriteEnabled = true
        depthStencilStateMap["default"] = spectraView.device?.newDepthStencilStateWithDescriptor(depthStateDesc)
    }
    
    func setupObjects() {
        // parse Cube.XML
        let bundle = NSBundle(forClass: CubeViewController.self)
        let path = bundle.pathForResource("Cube", ofType: "xml")
        let data = NSData(contentsOfFile: path!)
        let xml = SWXMLHash.parse(data!)
        
        let cubeXml = try! xml["root"]["mesh"].withAttr("id", cubeKey)
        setupCube(cubeKey, xml: cubeXml)
    }
    
    func setupCube(cubeKey: String, xml: XMLIndexer) {
        let cubeNode = Spectra.Node()
        let cubeGen = Spectra.CubeGenerator()
        cubeNode.data["position"] = cubeGen.getVertices()
        cubeNode.data["texcoords"] = cubeGen.getTexCoords()
        cubeNode.data["colorcoords"] = cubeGen.getColorCoords()
        cubeNode.dataMaps["triangle_vertex"] = cubeGen.getTriangleVertexMap()
        scene!.nodeMap[cubeKey] = cubeNode
        //nodeMap[cubeKey] =
    }
    
    func setupScene() {
        scene!.pipelineStateMap = pipelineStateMap
    }
    
}