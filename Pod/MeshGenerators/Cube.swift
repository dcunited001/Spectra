//
//  Cube.swift
//  Pods
//
//  Created by David Conner on 10/3/15.
//
//

import simd

public class CubeGenerator: MeshGenerator {
    
    public required init(args: [String: String] = [:]) {
        
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
    
    // return a node
    // - with a list of vertices
    // - with a list of colorvertices
    // - with a list of textureVertices
    // - a map of vertices to triangles (& reverse?)
    // - a map of vertices to faces (& reverse?)
    
    public func getVertices() -> [float4] {
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
    
    public func getColorCoords() -> [float4] {
        return [
            float4(1.0, 1.0, 1.0, 1.0),
            float4(0.0, 1.0, 1.0, 1.0),
            float4(1.0, 0.0, 1.0, 1.0),
            float4(1.0, 0.0, 0.0, 1.0),
            float4(0.0, 0.0, 1.0, 1.0),
            float4(1.0, 1.0, 0.0, 1.0),
            float4(0.0, 1.0, 0.0, 1.0),
            float4(0.0, 0.0, 0.0, 1.0)
        ]
    }
    
    public func getTexCoords() -> [float4] {
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
    
    public func getTriangleVertexMap() -> [[Int]] {
        let A = 0
        let B = 1
        let C = 2
        let D = 3
        let Q = 4
        let R = 5
        let S = 6
        let T = 7
        
        return [
            [A,B,C], [A,C,D],   //Front
            [R,T,S], [Q,R,S],   //Back
            
            [Q,S,B], [Q,B,A],   //Left
            [D,C,T], [D,T,R],   //Right
            
            [Q,A,D], [Q,D,R],   //Top
            [B,S,T], [B,T,C]   //Bottom
        ]
    }
    
    public func getFaceVertexMap() -> [[Int]] {
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
            [A,B,C,D],   //Front
            [Q,R,S,T],   //Back
            
            [Q,A,D,T],   //Left
            [B,R,S,C],   //Right
            
            [Q,R,B,A],   //Top
            [T,S,C,D]   //Bottom
        ]
    }
    
    public func getFaceTriangleMap() -> [[Int]] {
        return (0...5).map { [2 * $0, 2 * $0 + 1] }
    }
    
//    func getTextureVertices() -> [float4] {
//        return [
//        
//        ]
//    }
    
}
