//
//  SpectraNode.swift
//  Spectra
//
//  Created by David Conner on 9/25/15.
//  Copyright © 2015 Spectra. All rights reserved.
//

import Metal
import SWXMLHash
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

// TODO: for cube (and other polygons),
// - determine indexing functions for textures
// TODO: multi-perspective renderer
//
//protocol VertexBufferable {
//    var vCount:Int { get set }
//    var vBytes:Int { get set }
//    var vertexBufferId:Int { get set }
//    var vertexBuffer:MTLBuffer { get set }
//    var device:MTLDevice { get set }
//
//    func getVertexSize() -> Int
//    static func getVertexSize() -> Int
//    func getRawVertices() -> [protocol<Vertexable, Chunkable>]
//    func setVertexBuffer(vertices: [Vertexable])
//    static func calculateBytes(vertexCount: Int) -> Int
//}

//TODO: evaluate new vertexable/colorable/textureable protocols
// - do i really need to differentiate these protocols?
public protocol NodeVertexable {
    var vertexBuffer: EncodableBuffer? { get set }
}

public protocol NodeColorable {
    var colorBuffer: EncodableBuffer? { get set }
}

public protocol NodeTextureable {
    var textureBuffer: EncodableBuffer { get set }
}

public protocol Modelable: class {
    var modelScale:float4 { get set }
    var modelPosition:float4 { get set }
    var modelRotation:float4 { get set }
    var modelMatrix:float4x4 { get set }
    
    func setModelableDefaults()
    func calcModelMatrix() -> float4x4
    func updateModelMatrix()
    func setModelUniformsFrom(model: Modelable)
}

extension Modelable {
    public func setModelableDefaults() {
        modelPosition = float4(1.0, 1.0, 1.0, 1.0)
        modelScale = float4(1.0, 1.0, 1.0, 1.0)
        modelRotation = float4(1.0, 1.0, 1.0, 90.0)
    }
    
    public func calcModelMatrix() -> float4x4 {
        // scale, then rotate, then translate!!
        // - but it looks cooler identity * translate, rotate, scale
        return Transform3D.translate(modelPosition) *
            Transform3D.rotate(modelRotation) *
            Transform3D.scale(modelScale) // <== N.B. this scales first!!
    }
    
    public func updateModelMatrix() {
        modelMatrix = calcModelMatrix()
    }
    
    public func setModelUniformsFrom(model: Modelable) {
        modelPosition = model.modelPosition
        modelRotation = model.modelRotation
        modelScale = model.modelScale
        updateModelMatrix()
    }
}

public protocol Uniformable: class {
    //TODO: memoize uniformable matrix?
    var uniformScale:float4 { get set }
    var uniformPosition:float4 { get set }
    var uniformRotation:float4 { get set }
    
    //TODO: further split out MVP into separate protocol?
    var mvpMatrix:float4x4 { get set }
    var mvpBufferId:Int { get set }
    var mvpBuffer:MTLBuffer? { get set }
    var mvpPointer: UnsafeMutablePointer<Void>? { get set }
    
    func setUniformableDefaults()
    func calcUniformMatrix() -> float4x4
    func calcMvpMatrix(modelMatrix: float4x4) -> float4x4
    func updateMvpMatrix(modelMatrix: float4x4)
    func prepareMvpBuffer(device: MTLDevice)
    func prepareMvpPointer()
    func updateMvpBuffer()
}

//must deinit resources
extension Uniformable {
    public func setUniformableDefaults() {
        uniformScale = float4(1.0, 1.0, 1.0, 1.0) // provides more range to place objects in world
        uniformPosition = float4(0.0, 0.0, 1.0, 1.0)
        uniformRotation = float4(1.0, 1.0, 1.0, 90)
    }
    
    public func calcUniformMatrix() -> float4x4 {
        // scale, then rotate, then translate!!
        // - but it looks cooler identity * translate, rotate, scale
        return Transform3D.translate(uniformPosition) *
            Transform3D.rotate(uniformRotation) *
            Transform3D.scale(uniformScale) // <== N.B. this scales first!!
    }
    
    public func updateMvpMatrix(modelMatrix: float4x4) {
        self.mvpMatrix = calcMvpMatrix(modelMatrix)
    }
    
    public func prepareMvpPointer() {
        self.mvpPointer = mvpBuffer!.contents()
    }
    
    public func prepareMvpBuffer(device: MTLDevice) {
        self.mvpBuffer = device.newBufferWithLength(sizeof(float4x4), options: .CPUCacheModeDefaultCache)
        self.mvpBuffer?.label = "MVP Buffer"
    }
    
    public func updateMvpBuffer() {
        memcpy(mvpPointer!, &self.mvpMatrix, sizeof(float4x4))
    }
}

//protocol Uniformable?
// TODO: defaults for rotatable/translatable/scalable -- need to be able to access modelRotation from defaults
// TODO: use Self class for blocks in rotatable/translatable/scalable?

protocol Rotatable: Modelable {
    var rotationRate: Float { get set }
    func rotateForTime(t: CFTimeInterval, block: (Rotatable -> Float)?)
    
    var updateRotationalVectorRate: Float { get set }
    func updateRotationalVectorForTime(t: CFTimeInterval, block: (Rotatable -> float4)?)
}

extension Rotatable {
    public func rotateForTime(t: CFTimeInterval, block: (Rotatable -> Float)?) {
        // TODO: clean this up.  add applyRotation? as default extension to protocol?
        // - or set up 3D transforms as a protocol?
        let rotation = (rotationRate * Float(t)) * (block?(self) ?? 1)
        self.modelRotation.w += rotation
    }
    
    public func updateRotationalVectorForTime(t: CFTimeInterval, block: (Rotatable -> float4)?) {
        let rVector = (rotationRate * Float(t)) * (block?(self) ?? float4(1.0, 1.0, 1.0, 0.0))
        self.modelRotation += rVector
    }
}

protocol Translatable: Modelable {
    var translationRate: Float { get set }
    func translateForTime(t: CFTimeInterval, block: (Translatable -> float4)?)
}

extension Translatable {
    public func translateForTime(t: CFTimeInterval, block: (Translatable -> float4)?) {
        let translation = (translationRate * Float(t)) * (block?(self) ?? float4(0.0, 0.0, 0.0, 0.0))
        self.modelPosition += translation
    }
}

protocol Scalable: Modelable {
    var scaleRate: Float { get set }
    func scaleForTime(t: CFTimeInterval, block: (Scalable -> float4)?)
}

extension Scalable {
    public func scaleForTime(t: CFTimeInterval, block: (Scalable -> float4)?) {
        let scaleAmount = (scaleRate * Float(t)) * (block?(self) ?? float4(0.0, 0.0, 0.0, 0.0))
        self.modelScale += scaleAmount
    }
}


