//
//  TriangularQuadLatticeGenerator.swift
//  Pods
//
//  Created by David Conner on 10/22/15.
//
//

import Foundation
import simd

class TriangularQuadLatticeGenerator: MeshGenerator {
    
    var rowCount: Int
    var colCount: Int
    
    public required init(args: [String: String]) {
        rowCount = Int(args["rowCount"]!)!
        colCount = Int(args["colCount"]!)!
    }
    
    public func getData() -> [String:[float4]] {
        return [
            "pos": getVertices(),
            "rgba": getColorCoords(),
            "tex": getTexCoords()
        ]
    }
    
    public func getDataMaps() -> [String:[[Int]]] {
        return [
            "triangle_vertex_map": getTriangleVertexMap(),
            "face_vertex_map": getFaceTriangleMap()
        ]
    }
    
    public func getVertices() -> [float4] {
        return []
    }
    public func getColorCoords() -> [float4] {
        return []
    }
    public func getTexCoords() -> [float4] {
        return []
    }
    public func getTriangleVertexMap() -> [[Int]] {
        return []
    }
    public func getFaceTriangleMap() -> [[Int]] {
        return []
    }
}