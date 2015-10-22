//
//  Mesh.swift
//  Pods
//
//  Created by David Conner on 10/22/15.
//
//

import simd

public protocol Mesh {
    var data: [String: [float4]] { get set }
    var dataMaps: [String: [[Int]]] { get set }
}

public class BaseMesh: Mesh {
    public var data: [String: [float4]] = [:]
    public var dataMaps: [String: [[Int]]] = [:]
}
