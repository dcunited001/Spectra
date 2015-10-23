//
//  SpectraNode.swift
//  Spectra
//
//  Created by David Conner on 9/25/15.
//  Copyright © 2015 Spectra. All rights reserved.
//

import Metal
import simd

public typealias SceneNodeMap = [String:Node]
public typealias SceneNodeSelectorMap = [String:NodeSelector]

//TODO: separate node primitives from nodes to conserve memory
// - need to add a var with a reference to another node, from which data/dataMaps can be accessed
// - but separate uniforms/perspective/etc can be applied
// - this isn't necessary but would be awesome
public class Node: Modelable {
    public var data: [String:[float4]] = [:]
    public var dataMaps: [String:[[Int]]] = [:]
    
    public var modelScale = float4(1.0, 1.0, 1.0, 1.0)
    public var modelPosition = float4(0.0, 0.0, 0.0, 1.0)
    public var modelRotation = float4(1.0, 1.0, 1.0, 90)
    public var modelMatrix: float4x4 = float4x4(diagonal: float4(1.0,1.0,1.0,1.0))
    
    public init() {
        updateModelMatrix()
    }
}

public class NodeSelector {
    
}

public class SceneGraphResourceWriters {
    
}

