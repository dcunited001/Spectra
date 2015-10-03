//
//  Cube.swift
//  Pods
//
//  Created by David Conner on 10/3/15.
//
//

import Metal
import simd

class CubeGenerator: NodeGenerator {
    
    // return a node
    // - with a list of vertices
    // - with a list of colorvertices
    // - with a list of textureVertices
    // - a map of vertices to triangles (& reverse?)
    // - a map of vertices to faces (& reverse?)
    
    func getVertices() -> [float4] {
        return [
            float4(-1.0,  1.0,  1.0, 1.0),
            float4(-1.0, -1.0,  1.0, 1.0),
            float4( 1.0, -1.0,  1.0, 1.0),
            float4( 1.0,  1.0,  1.0, 1.0),
            float4(-1.0,  1.0, -1.0, 1.0),
            float4( 1.0,  1.0, -1.0, 1.0),
            float4(-1.0, -1.0, -1.0, 1.0),
            float4( 1.0, -1.0, -1.0, 1.0)
        ]
    }
    
    func getColorVertices() -> [float4] {
        return [
            float4(1.0, 1.0, 1.0, 0.5),
            float4(0.0, 1.0, 1.0, 0.5),
            float4(1.0, 0.0, 1.0, 0.5),
            float4(1.0, 0.0, 0.0, 0.5),
            float4(0.0, 0.0, 1.0, 0.5),
            float4(1.0, 1.0, 0.0, 0.5),
            float4(0.0, 1.0, 0.0, 0.5),
            float4(0.0, 0.0, 0.0, 0.5)
        ]
    }
    
    func getTextureVertices() -> [float4] {
        return [
            float4(0.0, 0.0, 0.0, 0.0),
            float4(0.0, 1.0, 0.0, 0.0),
            float4(1.0, 0.0, 0.0, 0.0),
            float4(1.0, 1.0, 0.0, 0.0),
            float4(1.0, 1.0, 0.0, 0.0),
            float4(0.0, 1.0, 0.0, 0.0),
            float4(1.0, 0.0, 0.0, 0.0),
            float4(0.0, 1.0, 0.0, 0.0)
        ]
    }
    
    //   Q --- R
    //  /|    /|
    // A --- B |
    // | T --| S
    // |/    |/
    // D --- C
    
    func getTriangleVertexMap() -> [Int:[Int]] {
        let A = 0
        let B = 1
        let C = 2
        let D = 3
        let Q = 4
        let R = 5
        let S = 6
        let T = 7
        
        return [
            0: [A,B,C], 1: [A,C,D],   //Front
            2: [R,T,S], 3: [Q,R,S],   //Back
            
            4: [Q,S,B], 5: [Q,B,A],   //Left
            6: [D,C,T], 7: [D,T,R],   //Right
            
            8: [Q,A,D], 9: [Q,D,R],   //Top
            10: [B,S,T], 11: [B,T,C]   //Bottom
        ]
    }
    
    func getFaceVertexMap() -> [Int:[Int]] {
        let A = 0
        let B = 1
        let C = 2
        let D = 3
        let Q = 4
        let R = 5
        let S = 6
        let T = 7
        
        //needs to be rewritten,
        // - so that vertices of face are invariant for rotations
        return [
            0: [A,B,C,D],   //Front
            1: [Q,R,S,T],   //Back
            
            2: [Q,A,D,T],   //Left
            3: [B,R,S,C],   //Right
            
            4: [Q,R,B,A],   //Top
            5: [T,S,C,D]   //Bottom
        ]
    }
    
//    func getTextureVertices() -> [float4] {
//        return [
//        
//        ]
//    }
    
}
