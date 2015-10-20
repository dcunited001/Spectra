//
//  Perspectable.swift
//  Pods
//
//  Created by David Conner on 10/9/15.
//
//

import simd

public protocol Perspectable: class {
    var persepctiveType: String { get set }
    var perspectiveArgs: [String: Float] { get set }
    
    func calcPerspectiveMatrix() -> float4x4
}

extension Perspectable {
    
    public func calcPerspectiveMatrix() -> float4x4 {
        switch persepctiveType {
        case "fov": return calcPerspectiveFov()
        default: return calcPerspectiveFov()
        }
    }
    
    public func calcPerspectiveFov() -> float4x4 {
        let fov = perspectiveArgs["fov"]!
        let angle = perspectiveArgs["angle"]!
        let aspect = perspectiveArgs["aspect"]!
        let near = perspectiveArgs["near"]!
        let far = perspectiveArgs["far"]!
        
        return Transform3D.perspectiveFov(angle, aspect: aspect, near: near, far: far)
    }
    
    public func calcPerspectiveFrustumOC() -> float4x4 {
        let fov = perspectiveArgs["fov"]!
        let angle = perspectiveArgs["angle"]!
        let aspect = perspectiveArgs["aspect"]!
        let near = perspectiveArgs["near"]!
        let far = perspectiveArgs["far"]!
        
        let rAngle = Transform3D.toRadians(angle)
        let length = near * tan(rAngle)
        
        let right = length / aspect
        let left = -right
        let top = length
        let bottom = -top
        
        // alternate perspective using frustum_oc
        return Transform3D.frustum_oc(left, right: right, bottom: bottom, top: top, near: near, far: far)
    }
    
    public func calcPerspectiveFrustumOCEyeTracking() -> float4x4 {
        // haha maybe soon
        return float4x4()
    }
}

