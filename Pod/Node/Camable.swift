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
    
    func setCamDefaults()
    func calcCam() -> float4x4
}

// TODO: must deinit resources?
public extension Camable {
    public func setCamDefaults() {
        camEye =    [0.0, 0.0, 0.0, 1.0] //position
        camCenter = [0.0, 0.0, 1.0, 1.0] //position
        camUp =     [0.0, 1.0, 0.0, 0.0] //direction
    }
    
    public func calcCam() -> float4x4 {
        return Transform3D.lookAt(camEye, center: camCenter, up: camUp)
    }
}

public class BaseCamera: Camable {
    public var camEye = float4()
    public var camCenter = float4()
    public var camUp = float4()
    
    public init() {
        setCamDefaults()
    }
}
