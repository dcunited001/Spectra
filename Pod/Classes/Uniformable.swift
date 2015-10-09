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
