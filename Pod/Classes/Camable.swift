//
//  Camable.swift
//  Pods
//
//  Created by David Conner on 10/9/15.
//
//

import simd

public protocol Camable: class {
    //TODO: memoize camable matrix?
    var camEye:float4 { get set }
    var camCenter:float4 { get set }
    var camUp:float4 { get set }
    
    func setProjectableDefaults()
    func calcProjectionMatrix() -> float4x4
}

// TODO: must deinit resources?
public extension Camable {
    public func setProjectableDefaults() {
        camEye =    [0.0, 0.0, 0.0, 1.0] //position
        camCenter = [0.0, 0.0, 1.0, 1.0] //position
        camUp =     [0.0, 1.0, 0.0, 0.0] //direction
    }
    
    public func calcProjectionMatrix() -> float4x4 {
        return Transform3D.lookAt(camEye, center: camCenter, up: camUp)
    }
}
