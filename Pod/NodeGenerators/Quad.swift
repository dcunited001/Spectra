//
//  Quad.swift
//  Pods
//
//  Created by David Conner on 10/3/15.
//
//

import simd

public class QuadGenerator: NodeGenerator {
    
    public init() {
        
    }
    
    public func getVertices() -> [float4] {
        return [
            float4(-1.0, -1.0, 0.0, 1.0),
            float4(-1.0,  1.0, 0.0, 1.0),
            float4( 1.0, -1.0, 0.0, 1.0),
            float4( 1.0,  1.0, 0.0, 1.0)
        ]
    }

    public func getColorCoords() -> [float4] {
        return [
            float4(1.0, 0.0, 0.0, 1.0),
            float4(0.0, 1.0, 0.0, 1.0),
            float4(0.0, 0.0, 1.0, 1.0),
            float4(1.0, 1.0, 0.0, 1.0)
        ]
    }
    
    public func getTexCoords() -> [float4] {
        return [
            float4(0.0, 0.0, 0.0, 0.0),
            float4(0.0, 1.0, 0.0, 0.0),
            float4(1.0, 0.0, 0.0, 0.0),
            float4(1.0, 1.0, 0.0, 0.0)
        ]
    }
    
    public func getTriangleVertexMap() -> [[Int]] {
        return [
            [0,1,3],
            [3,2,0]
        ]
    }
    
    public func getFaceVertexMap() -> [[Int]] {
        return [[0,1,2,3]]
    }
    
    public func getFaceTriangleMap() -> [[Int]] {
        return [[0,1]]
    }
}
