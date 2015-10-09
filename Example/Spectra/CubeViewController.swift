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
    var nodeMap: Spectra.SceneNodeMap = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadPipelineStateMap()
        loadDepthStencilMap()
        setupScene()
    }
    
    func loadPipelineStateMap() {
        let pipelineGenerator = Spectra.RenderPipelineGenerator(library: spectraView.defaultLibrary)
        pipelineStateMap = pipelineGenerator.generatePipelineMap(spectraView.device!, functionMap: CubeViewController.renderFunctionMap)
    }
    
    func loadDepthStencilMap() {
        let depthStateDesc = MTLDepthStencilDescriptor()
        depthStateDesc.depthCompareFunction = .Always
        depthStateDesc.depthWriteEnabled = true
        depthStencilStateMap["default"] = spectraView.device?.newDepthStencilStateWithDescriptor(depthStateDesc)
    }
    
    func setupScene() {
        scene = Spectra.Scene()
        scene!.pipelineStateMap = pipelineStateMap
        scene!.nodeMap = nodeMap
        
    }
    
}