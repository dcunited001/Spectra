//
//  Quad.swift
//  Pods
//
//  Created by David Conner on 10/3/15.
//
//

import simd

class QuadGenerator: NodeGenerator {
    func getVertices() -> [float4] {
        return [
            float4(-1.0, -1.0, 0.0, 1.0),
            float4(-1.0,  1.0, 0.0, 1.0),
            float4( 1.0, -1.0, 0.0, 1.0),
            float4( 1.0,  1.0, 0.0, 1.0)
        ]
    }

    func getColorCoords() -> [float4] {
        return [
            float4(1.0, 0.0, 0.0, 1.0),
            float4(0.0, 1.0, 0.0, 1.0),
            float4(0.0, 0.0, 1.0, 1.0),
            float4(1.0, 1.0, 0.0, 1.0)
        ]
    }
    
    func getTexCoords() -> [float4] {
        return [
            float4(0.0, 0.0, 0.0, 0.0),
            float4(0.0, 1.0, 0.0, 0.0),
            float4(1.0, 0.0, 0.0, 0.0),
            float4(1.0, 1.0, 0.0, 0.0)
        ]
    }
    
    func getTriangleVertexMap() -> [[Int]] {
        return [
            [0,1,3],
            [3,2,0]
        ]
    }
    
    func getFaceVertexMap() -> [[Int]] {
        return [[0,1,2,3]]
    }
    
    func getFaceTriangleMap() -> [[Int]] {
        return [[0,1]]
    }
}
