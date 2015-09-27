//
//  SpectraNode.swift
//  Spectra
//
//  Created by David Conner on 9/25/15.
//  Copyright © 2015 Spectra. All rights reserved.
//

import Metal
import simd

protocol SpectraRenderEncodable {
    func encode(renderEncoder: MTLRenderCommandEncoder)
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
protocol SpectraNodeVertexable {
    var vertexBuffer: SpectraBuffer? { get set }
}

protocol SpectraNodeColorable {
    var colorBuffer: SpectraBuffer? { get set }
}

protocol SpectraNodeTextureable {
    var textureBuffer: SpectraBuffer { get set }
}

class SpectraNode: SpectraModelable {
    var vertexBuffer: SpectraBuffer?
    var buffers: [SpectraBuffer] = []
    
    var device:MTLDevice
    
    // Modelable
    var modelScale = float4(1.0, 1.0, 1.0, 1.0)
    var modelPosition = float4(0.0, 0.0, 0.0, 1.0)
    var modelRotation = float4(1.0, 1.0, 1.0, 90)
    var modelMatrix: float4x4 = float4x4(diagonal: float4(1.0,1.0,1.0,1.0))
    
    // TODO: reorder params
    init(name: String, vertices: [float4], device: MTLDevice) {
        self.device = device
        
        self.vCount = vertices.count
        self.vBytes = Node<T>.calculateBytes(vCount)
        self.vertexBuffer = self.device.newBufferWithBytes(vertices, length: vBytes, options: .CPUCacheModeDefaultCache)
        self.vertexBuffer.label = "\(T.self) vertices"
        updateModelMatrix()
    }
    
//    func getRawVertices() -> [protocol<Vertexable, Chunkable>] {
//        return []
//    }
//    
//    func getVertexSize() -> Int {
//        return sizeof(T)
//    }
//    
//    static func getVertexSize() -> Int {
//        return sizeof(T)
//    }
//    
//    static func calculateBytes(vertexCount: Int) -> Int {
//        return vertexCount * sizeof(T)
//    }
}

protocol SpectraModelable: class {
    var modelScale:float4 { get set }
    var modelPosition:float4 { get set }
    var modelRotation:float4 { get set }
    var modelMatrix:float4x4 { get set }
    
    func setModelableDefaults()
    func calcModelMatrix() -> float4x4
    func updateModelMatrix()
    func setModelUniformsFrom(model: SpectraModelable)
}

extension SpectraModelable {
    func setModelableDefaults() {
        modelPosition = float4(1.0, 1.0, 1.0, 1.0)
        modelScale = float4(1.0, 1.0, 1.0, 1.0)
        modelRotation = float4(1.0, 1.0, 1.0, 90.0)
    }
    
    func calcModelMatrix() -> float4x4 {
        // scale, then rotate, then translate!!
        // - but it looks cooler identity * translate, rotate, scale
        return Spectra3DTransforms.translate(modelPosition) *
            Spectra3DTransforms.rotate(modelRotation) *
            Spectra3DTransforms.scale(modelScale) // <== N.B. this scales first!!
    }
    
    func updateModelMatrix() {
        modelMatrix = calcModelMatrix()
    }
    
    func setModelUniformsFrom(model: SpectraModelable) {
        modelPosition = model.modelPosition
        modelRotation = model.modelRotation
        modelScale = model.modelScale
        updateModelMatrix()
    }
}
protocol SpectraUniformable: class {
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
extension SpectraUniformable {
    func setUniformableDefaults() {
        uniformScale = float4(1.0, 1.0, 1.0, 1.0) // provides more range to place objects in world
        uniformPosition = float4(0.0, 0.0, 1.0, 1.0)
        uniformRotation = float4(1.0, 1.0, 1.0, 90)
    }
    
    func calcUniformMatrix() -> float4x4 {
        // scale, then rotate, then translate!!
        // - but it looks cooler identity * translate, rotate, scale
        return Spectra3DTransforms.translate(uniformPosition) *
            Spectra3DTransforms.rotate(uniformRotation) *
            Spectra3DTransforms.scale(uniformScale) // <== N.B. this scales first!!
    }
    
    func updateMvpMatrix(modelMatrix: float4x4) {
        self.mvpMatrix = calcMvpMatrix(modelMatrix)
    }
    
    func prepareMvpPointer() {
        self.mvpPointer = mvpBuffer!.contents()
    }
    func prepareMvpBuffer(device: MTLDevice) {
        self.mvpBuffer = device.newBufferWithLength(sizeof(float4x4), options: .CPUCacheModeDefaultCache)
        self.mvpBuffer?.label = "MVP Buffer"
    }
    
    func updateMvpBuffer() {
        memcpy(mvpPointer!, &self.mvpMatrix, sizeof(float4x4))
    }
}

protocol SpectraPerspectable: class {
    var perspectiveFov:Float { get set }
    var perspectiveAngle:Float { get set } // view orientation to user in degrees =) 3d
    var perspectiveAspect:Float { get set } // update when view bounds change
    var perspectiveNear:Float { get set }
    var perspectiveFar:Float { get set }
    
    func setPerspectiveDefaults()
    func calcPerspectiveMatrix() -> float4x4
}

extension SpectraPerspectable {
    func setPerspectiveDefaults() {
        perspectiveFov = 65.0
        perspectiveAngle = 35.0 // 35.0 for landscape
        perspectiveAspect = 1
        perspectiveNear = 0.01
        perspectiveFar = 100.0
    }
    
    func calcPerspectiveMatrix() -> float4x4 {
        let rAngle = Spectra3DTransforms.toRadians(perspectiveAngle)
        let length = perspectiveNear * tan(rAngle)
        
        let right = length / perspectiveAspect
        let left = -right
        let top = length
        let bottom = -top
        
        return Spectra3DTransforms.perspectiveFov(perspectiveAngle, aspect: perspectiveAspect, near: perspectiveNear, far: perspectiveFar)
        
        // alternate perspective using frustum_oc
        //        return Metal3DTransforms.frustum_oc(left, right: right, bottom: bottom, top: top, near: perspectiveNear, far: perspectiveFar)
    }
}

//protocol Uniformable?
// TODO: defaults for rotatable/translatable/scalable -- need to be able to access modelRotation from defaults

protocol SpectraRotatable: SpectraModelable {
    var rotationRate: Float { get set }
    func rotateForTime(t: CFTimeInterval, block: (SpectraRotatable -> Float)?)
    
    var updateRotationalVectorRate: Float { get set }
    func updateRotationalVectorForTime(t: CFTimeInterval, block: (SpectraRotatable -> float4)?)
}

extension SpectraRotatable {
    func rotateForTime(t: CFTimeInterval, block: (SpectraRotatable -> Float)?) {
        // TODO: clean this up.  add applyRotation? as default extension to protocol?
        // - or set up 3D transforms as a protocol?
        let rotation = (rotationRate * Float(t)) * (block?(self) ?? 1)
        self.modelRotation.w += rotation
    }
    
    
    func updateRotationalVectorForTime(t: CFTimeInterval, block: (SpectraRotatable -> float4)?) {
        let rVector = (rotationRate * Float(t)) * (block?(self) ?? float4(1.0, 1.0, 1.0, 0.0))
        self.modelRotation += rVector
    }
}

protocol SpectraTranslatable: SpectraModelable {
    var translationRate: Float { get set }
    func translateForTime(t: CFTimeInterval, block: (SpectraTranslatable -> float4)?)
}

extension SpectraTranslatable {
    func translateForTime(t: CFTimeInterval, block: (SpectraTranslatable -> float4)?) {
        let translation = (translationRate * Float(t)) * (block?(self) ?? float4(0.0, 0.0, 0.0, 0.0))
        self.modelPosition += translation
    }
}

protocol SpectraScalable: SpectraModelable {
    var scaleRate: Float { get set }
    func scaleForTime(t: CFTimeInterval, block: (SpectraScalable -> float4)?)
}

extension SpectraScalable {
    func scaleForTime(t: CFTimeInterval, block: (SpectraScalable -> float4)?) {
        let scaleAmount = (scaleRate * Float(t)) * (block?(self) ?? float4(0.0, 0.0, 0.0, 0.0))
        self.modelScale += scaleAmount
    }
}







