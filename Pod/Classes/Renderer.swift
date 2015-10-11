//
//  SpectraRenderer.swift
//  Spectra
//
//  Created by David Conner on 9/27/15.
//  Copyright © 2015 Spectra. All rights reserved.
//

import simd
import MetalKit

public typealias RendererEncodeBlock = ((MTLRenderCommandEncoder) -> Void)
public typealias RenderEncoderConfigureBlock = ((MTLRenderCommandEncoder) -> Void)
public typealias RenderEncoderTransition = ((MTLRenderCommandEncoder) -> MTLRenderCommandEncoder)
public typealias RenderEncoderTransitionMap = [String:RenderEncoderTransition]
public typealias RenderEncoderCreateMonad = ((MTLCommandBuffer, MTLRenderPassDescriptor) -> MTLRenderCommandEncoder)

public protocol Renderer {
    var name: String? { get set }
    var transitionMap: RenderEncoderTransitionMap { get set }
    var createRenderEncoderBlock: RenderEncoderCreateMonad? { get set }
    
    // should these kinds of properties only be set from inside blocks?
    var cullMode: MTLCullMode { get set }
    
    // additional renderEncoder .set() commands that always need to be executed after a transition returns a new renderEncoder 
    // - and also for used renderEncoders??
    var configureRenderEncoderBlock: RenderEncoderConfigureBlock? { get set }

    func encode(renderEncoder: MTLRenderCommandEncoder, encodeBlock: RendererEncodeBlock)
    func configure(renderEncoder: MTLRenderCommandEncoder)
    func transitionRenderEncoderTo(renderer: Renderer?) -> RenderEncoderTransition?
    func defaultRenderEncoderTransition() -> RenderEncoderCreateMonad
}

extension Renderer {
    
    public func encode(renderEncoder: MTLRenderCommandEncoder, encodeBlock: RendererEncodeBlock) {
        
    }
    
    public func configure(renderEncoder: MTLRenderCommandEncoder) {
        renderEncoder.setCullMode(cullMode)
        configureRenderEncoderBlock?(renderEncoder)
    }

    public func defaultRenderEncoderTransition() -> RenderEncoderCreateMonad {
        return createRenderEncoderBlock!
    }
    
    public func transitionRenderEncoderTo(renderer: Renderer?) -> RenderEncoderTransition? {
        if let rendererType = renderer?.name {
            return transitionMap[rendererType]
        } else {
            //TODO: more 'eloquent' way to return here? or to structure this functions?
            return nil
        }
    }
    
}

//typealias ComputeEncoderTransition = ((MTLCommandBuffer, MTLComputeCommandEncoder) -> MTLComputeCommandEncoder)

public class BaseRenderer: Renderer {
    public var name: String?
    public var transitionMap: RenderEncoderTransitionMap = [:]
    public var createRenderEncoderBlock: RenderEncoderCreateMonad? = BaseRenderer.createRenderEncoderDefault()
    public var configureRenderEncoderBlock: RenderEncoderConfigureBlock?
    
    public var cullMode: MTLCullMode = .Front
    
    class func createRenderEncoderDefault() -> RenderEncoderCreateMonad {
        return { (cmdBuffer, renderPassDescriptor) in
            return cmdBuffer.renderCommandEncoderWithDescriptor(renderPassDescriptor)
        }
    }
    
}

//struct MetalInterfaceOrientation {
//    var LandscapeAngle:Float = 35.0
//    var PortraitAngle:Float = 50.0
//}
//
//struct Perspective {
//    var Near:Float = 0.1
//    var Far:Float = 100.0
//}

//public class BaseRenderer {

//    var colorPixelFormat: MTLPixelFormat? = .BGRA8Unorm
//    var depthPixelFormat: MTLPixelFormat? = .Depth32Float
//    var stencilPixelFormat: MTLPixelFormat?
    
    // this value will cycle from 0 to kInFlightCommandBuffers whenever a display completes ensuring renderer clients
    // can synchronize between kInFlightCommandBuffers count buffers, and thus avoiding a constant buffer from being overwritten between draws
//}

//class MVPRenderer: BaseRenderer, Projectable, Uniformable, Perspectable {
//    var pipelineState: MTLRenderPipelineState?
//    var size = CGSize() // TODO: more descriptive name
//    var startTime = CFAbsoluteTimeGetCurrent()
//    
//    var object: protocol<Renderer,Modelable>?
//    
//    var vertexShaderName = "basic_triangle_vertex"
//    var fragmentShaderName = "basic_triangle_fragment"
//    
//    //Perspectable
//    var perspectiveFov:Float = 65.0
//    var perspectiveAngle:Float = 35.0
//    var perspectiveAspect:Float = 1
//    var perspectiveNear:Float = 0.01
//    var perspectiveFar:Float = 100
//    
//    //Projectable
//    var projectionEye: float3 = [0.0, 0.0, 0.0]
//    var projectionCenter: float3 = [0.0, 0.0, 1.0]
//    var projectionUp: float3 = [0.0, 1.0, 0.0]
//    
//    // Uniformable
//    var uniformScale: float4 = float4(1.0, 1.0, 1.0, 1.0)
//    var uniformPosition: float4 = float4(0.0, 0.0, 0.0, 1.0)
//    var uniformRotation: float4 = float4(1.0, 1.0, 1.0, 90)
//    
//    var mvpMatrix:float4x4 = float4x4(diagonal: float4(1.0,1.0,1.0,1.0))
//    var mvpBuffer:MTLBuffer?
//    var mvpBufferId:Int = 1
//    var mvpPointer: UnsafeMutablePointer<Void>?
//    
//    var rendererDebugGroupName = "Encode BaseRenderer"
//    
//    deinit {
//        //TODO: release mvp
//    }
//    
//    override init() {
//        super.init()
//    }
//    
//    func configure(view: BaseView) {
//        setPerspectiveDefaults()
//        setProjectableDefaults()
//        setUniformableDefaults()
//        
//        adjustUniformScale(view)
//        prepareMvpBuffer(device!)
//        prepareMvpPointer()
//        
//        guard preparePipelineState(view) else {
//            print("Failed creating a compiled pipeline state object!")
//            return
//        }
//    }
//    
//    func adjustUniformScale(view: BaseView) {
//        uniformScale *= float4(1.0, Float(view.frame.width / view.frame.height), 1.0, 1.0)
//    }
//    
//    func preparePipelineState(view: BaseView) -> Bool {
//        guard let vertexProgram = shaderLibrary?.newFunctionWithName(vertexShaderName) else {
//            print("Couldn't load \(vertexShaderName)")
//            return false
//        }
//        
//        guard let fragmentProgram = shaderLibrary?.newFunctionWithName(fragmentShaderName) else {
//            print("Couldn't load \(fragmentShaderName)")
//            return false
//        }
//        
//        //setup render pipeline descriptor
//        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
//        pipelineStateDescriptor.vertexFunction = vertexProgram
//        pipelineStateDescriptor.fragmentFunction = fragmentProgram
//        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .BGRA8Unorm
////        MTLRenderPassDescriptor
//        //setup render pipeline state
//        do {
//            try pipelineState = device!.newRenderPipelineStateWithDescriptor(pipelineStateDescriptor)
//        } catch(let err) {
//            print("Failed to create pipeline state, error \(err)")
//        }
//        
//        return true
//    }
//    
//    override func encode(renderEncoder: MTLRenderCommandEncoder) {
//        super.encode(renderEncoder)
//        renderEncoder.pushDebugGroup(rendererDebugGroupName)
//        renderEncoder.setRenderPipelineState(pipelineState!)
////        object!.encode(renderEncoder)
//        encodeVertexBuffers(renderEncoder)
//        encodeFragmentBuffers(renderEncoder)
//        encodeDraw(renderEncoder)
//        renderEncoder.popDebugGroup()
//        renderEncoder.endEncoding()
//    }
//    
//    func renderObjects(drawable: CAMetalDrawable, renderPassDescriptor: MTLRenderPassDescriptor, commandBuffer: MTLCommandBuffer) {
//        updateMvpMatrix(object!.modelMatrix)
//        updateMvpBuffer()
//        let renderEncoder = commandBuffer.renderCommandEncoderWithDescriptor(renderPassDescriptor)
//        self.encode(renderEncoder)
//    }
//    
//    func updateLogic(timeSinceLastUpdate: CFTimeInterval) {
//        object!.updateModelMatrix()
//    }
//    
//    func encodeVertexBuffers(renderEncoder: MTLRenderCommandEncoder) {
//        renderEncoder.setVertexBuffer(mvpBuffer, offset: 0, atIndex: mvpBufferId)
//    }
//    
//    func encodeFragmentBuffers(renderEncoder: MTLRenderCommandEncoder) {
//        
//    }
//    
//    func encodeDraw(renderEncoder: MTLRenderCommandEncoder) {
//        //        renderEncoder.drawPrimitives(.Triangle, vertexStart: 0, vertexCount: object!.vCount, instanceCount: 1)
//    }
//}
