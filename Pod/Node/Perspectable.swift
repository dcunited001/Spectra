//
//  Perspectable.swift
//  Pods
//
//  Created by David Conner on 10/9/15.
//
//

import simd

public protocol Perspectable: class {
    var perspectiveType: String { get set }
    var perspectiveArgs: [String: Float] { get set }
    
    func setPerspectiveDefaults()
    func calcPerspectiveMatrix() -> float4x4
}

extension Perspectable {
    
    public func calcPerspectiveMatrix() -> float4x4 {
        switch perspectiveType {
        case "fov": return calcPerspectiveFov()
        case "frustum_oc": return calcPerspectiveFrustumOC()
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
    
    public func setPerspectiveDefaults() {
        self.perspectiveType = "fov"
        self.perspectiveArgs = [
            "fov": 65.0,
            "angle": 35.0,
            "aspect": 1.0,
            "near": 0.01,
            "far": 100.0
        ]
    }
}

public class BasePerspectable: Perspectable {
    public var perspectiveType: String = "fov"
    public var perspectiveArgs: [String:Float] = [:]
    
    public init() {
        setPerspectiveDefaults()
    }
    
}

