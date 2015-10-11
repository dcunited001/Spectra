//
//  Modelable.swift
//  Pods
//
//  Created by David Conner on 10/9/15.
//
//

import simd

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

