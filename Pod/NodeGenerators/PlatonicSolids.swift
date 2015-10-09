//
//  PlatonicSolids.swift
//  Pods
//
//  Created by David Conner on 10/3/15.
//
//

import simd

//N.B. textures are 1-to-1 with vertex-face map
// - for simple 3d objects

public class TetrahedronGenerator: NodeGenerator {
    
    public init() {
        
    }
    
    public func getVertices() -> [float4] {
        return [
            float4( 1.0,  1.0,  1.0, 1.0),
            float4(-1.0,  1.0, -1.0, 1.0),
            float4( 1.0, -1.0, -1.0, 1.0),
            float4(-1.0, -1.0,  1.0, 1.0)
        ]
    }
    
    public func getColorCoords() -> [float4] {
        return [
            float4(1.0, 1.0, 1.0, 1.0),
            float4(1.0, 0.0, 0.0, 1.0),
            float4(0.0, 1.0, 0.0, 1.0),
            float4(0.0, 0.0, 1.0, 1.0)
        ]
    }
    
    public func getTexCoords() -> [float4] {
        return [
            float4(1.0, 1.0, 0.0, 0.0),
            float4(1.0, 0.0, 0.0, 0.0),
            float4(0.0, 1.0, 0.0, 0.0),
            float4(0.0, 0.0, 0.0, 0.0)
        ]
    }
    
    public func getTriangleVertexMap() -> [[Int]] {
        return [
            [0,1,2],
            [1,3,2],
            [0,2,3],
            [0,3,1]
        ]
    }
    
    public func getFaceVertexMap() -> [[Int]] {
        return getTriangleVertexMap()
    }
    
    public func getFaceTriangleMap() -> [[Int]] {
        return (0...3).map { [$0] }
    }
}

public class OctahedronGenerator: NodeGenerator {
    
    public init() {
        
    }
    
    let A = Float(1 / (2 * sqrt(2.0)))
    let B = Float(1 / 2.0)
    
    public func getVertices() -> [float4] {
        return [
            float4( 0,  B,  0, 1.0),
            float4( A,  0,  A, 1.0),
            float4( A,  0, -A, 1.0),
            float4(-A,  0,  A, 1.0),
            float4(-A,  0, -A, 1.0),
            float4( 0, -B,  0, 1.0)
        ]
    }

    public func getColorCoords() -> [float4] {
        return [
            float4(1.0, 1.0, 1.0, 1.0), // white
            float4(1.0, 0.0, 0.0, 1.0), // red
            float4(0.0, 1.0, 0.0, 1.0), // blue
            float4(0.0, 0.0, 1.0, 1.0), // green
            float4(1.0, 1.0, 0.0, 1.0), // yellow
            float4(0.0, 0.0, 0.0, 0.0), // transparent
        ]
    }

    public func getTexCoords() -> [float4] {
        return [
            float4(0.0, 0.0, 0.0, 0.0),
            float4(0.0, 1.0, 0.0, 0.0),
            float4(1.0, 0.0, 0.0, 0.0),
            float4(0.0, 1.0, 0.0, 0.0),
            float4(1.0, 0.0, 0.0, 0.0),
            float4(1.0, 1.0, 0.0, 0.0)
        ]
    }

    public func getTriangleVertexMap() -> [[Int]] {
        return [
            [0,1,2],
            [0,2,3],
            [0,3,4],
            [0,4,1],
            [5,1,2],
            [5,2,3],
            [5,3,4],
            [5,4,1]
        ]
    }

    public func getFaceVertexMap() -> [[Int]] {
        return getTriangleVertexMap()
    }
    
    public func getFaceTriangleMap() -> [[Int]] {
        return (0...7).map { [$0] }
    }
}

//http://paulbourke.net/geometry/platonic/
//public class IcosahedronGenerator: NodeGenerator { }
//public class DodecahderonGenerator: NodeGenerator { }
//public class Dodecahderon2Generator: NodeGenerator { }
// - where vertex in center of pentagons
//class Dodecahderon3: NodeGenerator { }
// - with overlapping triangles

//public class TetrahedronGenerator: NodeGenerator {
//    func getVertices() -> [float4] {
//        return [
//            
//        ]
//    }
//    
//    func getColorCoords() -> [float4] {
//        return [
//            
//        ]
//    }
//    
//    func getTexCoords() -> [float4] {
//        return [
//            
//        ]
//    }
//    
//    func getTriangleVertexMap() -> [[Int]] {
//        return [[]]
//    }
//    
//    func getFaceVertexMap() -> [[Int]] {
//        return [[]]
//    }
//}