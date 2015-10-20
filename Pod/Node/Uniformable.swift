//
//  Uniformable.swift
//  Pods
//
//  Created by David Conner on 10/9/15.
//
//

import simd

public protocol Uniformable: class {
    //TODO: memoize uniformable matrix?
    var uniformScale:float4 { get set }
    var uniformPosition:float4 { get set }
    var uniformRotation:float4 { get set }
    
    func setUniformableDefaults()
    func calcUniformMatrix() -> float4x4
}

extension Uniformable {
    public func setUniformableDefaults() {
        uniformScale = float4(1.0, 1.0, 1.0, 1.0)
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
}

public class BaseUniforms: Uniformable {
    public var uniformScale = float4()
    public var uniformPosition = float4()
    public var uniformRotation = float4()
    
    public init() {
        setUniformableDefaults()
    }
}

public protocol HasMVPInput: class {
    var mvpInput: BaseEncodableInput<float4x4>? { get set }
    func calcMvp() -> float4x4
    func updateMvp()
}

extension HasMVPInput {
    public func updateMvp() {
        self.mvpInput?.data = calcMvp()
    }
}
