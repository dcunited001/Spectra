//
//  Perspectable.swift
//  Pods
//
//  Created by David Conner on 10/9/15.
//
//

import simd

public protocol Perspectable: class {
    var perspectiveFov:Float { get set }
    var perspectiveAngle:Float { get set } // view orientation to user in degrees =) 3d
    var perspectiveAspect:Float { get set } // update when view bounds change
    var perspectiveNear:Float { get set }
    var perspectiveFar:Float { get set }
    
    func setPerspectiveDefaults()
    func calcPerspectiveMatrix() -> float4x4
}

extension Perspectable {
    public func setPerspectiveDefaults() {
        perspectiveFov = 65.0
        perspectiveAngle = 35.0 // 35.0 for landscape
        perspectiveAspect = 1
        perspectiveNear = 0.01
        perspectiveFar = 100.0
    }
    
    public func calcPerspectiveMatrix() -> float4x4 {
        let rAngle = Transform3D.toRadians(perspectiveAngle)
        let length = perspectiveNear * tan(rAngle)
        
        let right = length / perspectiveAspect
        let left = -right
        let top = length
        let bottom = -top
        
        return Transform3D.perspectiveFov(perspectiveAngle, aspect: perspectiveAspect, near: perspectiveNear, far: perspectiveFar)
        
        // alternate perspective using frustum_oc
        //        return Metal3DTransforms.frustum_oc(left, right: right, bottom: bottom, top: top, near: perspectiveNear, far: perspectiveFar)
    }
}

