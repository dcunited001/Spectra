//
//  SpectraRenderer.swift
//  Spectra
//
//  Created by David Conner on 9/27/15.
//  Copyright © 2015 Spectra. All rights reserved.
//

import simd
import MetalKit

typealias RendererEncodeBlock = ((MTLRenderCommandEncoder) -> Void)
typealias RenderEncoderTransition = ((MTLCommandBuffer, MTLRenderCommandEncoder, MTLRenderCommandEncoder?) -> MTLRenderCommandEncoder)

protocol Renderer {
    var transitionMap: [String:RenderEncoderTransition] { get set }
    
    func encode(renderEncoder: MTLRenderCommandEncoder)
    func encode(renderEncoder: MTLRenderCommandEncoder, encodeBlock: RendererEncodeBlock)
    func transitionTo(renderer: Renderer?) -> Renderer
    func defaultTransition(commandBuffer: MTLCommandBuffer) -> MTLRenderCommandEncoder
}

//typealias ComputeEncoderTransition = ((MTLCommandBuffer, MTLComputeCommandEncoder) -> MTLComputeCommandEncoder)

class RendererBase: Renderer {
    var rendererType: Int = 0 // use enum for renderer types
    var transitionMap: [Int:RenderEncoderTransition] = [:]
    var createRenderEncoderBlock: RenderEncoderCreateMonad? = RendererBase.createRenderEncoderDefault()
    
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

class BaseRenderer {
    
    var device: MTLDevice?
    var commandQueue: MTLCommandQueue?
    var shaderLibrary: MTLLibrary?
    var depthState: MTLDepthStencilState?
    let kInFlightCommandBuffers = 3
    
    var colorPixelFormat: MTLPixelFormat? = .BGRA8Unorm
    var depthPixelFormat: MTLPixelFormat? = .Depth32Float
    var stencilPixelFormat: MTLPixelFormat?
    
    var cullMode: MTLCullMode = .Front
    
    // this value will cycle from 0 to kInFlightCommandBuffers whenever a display completes ensuring renderer clients
    // can synchronize between kInFlightCommandBuffers count buffers, and thus avoiding a constant buffer from being overwritten between draws
    
    init() {
        //        mConstantDataBufferIndex = 0
        //        avaliableResourcesSemaphore = dispatch_semaphore_create(kInFlightCommandBuffers)
    }
    
    deinit {
        //        for i in 0...self.kInFlightCommandBuffers{
        //            dispatch_semaphore_signal(avaliableResourcesSemaphore)
        //        }
    }
    
    func configure(view: MTKView) {
        depthPixelFormat = .Depth32Float
        view.colorPixelFormat = MTLPixelFormat.BGRA8Unorm // ?? correct
        stencilPixelFormat = MTLPixelFormat.Invalid
        view.sampleCount = 1
        
        guard let viewDevice = view.device else {
            print("Failed retrieving device from view")
            return
        }
        
        device = viewDevice
        commandQueue = device!.newCommandQueue()
        shaderLibrary = device!.newDefaultLibrary()
    }
    
    func encode(renderEncoder: MTLRenderCommandEncoder) {
        renderEncoder.setCullMode(cullMode)
    }
}

class MVPRenderer: BaseRenderer, Projectable, Uniformable, Perspectable {
    var pipelineState: MTLRenderPipelineState?
    var size = CGSize() // TODO: more descriptive name
    var startTime = CFAbsoluteTimeGetCurrent()
    
    var object: protocol<Renderer,Modelable>?
    
    var vertexShaderName = "basic_triangle_vertex"
    var fragmentShaderName = "basic_triangle_fragment"
    
    //Perspectable
    var perspectiveFov:Float = 65.0
    var perspectiveAngle:Float = 35.0
    var perspectiveAspect:Float = 1
    var perspectiveNear:Float = 0.01
    var perspectiveFar:Float = 100
    
    //Projectable
    var projectionEye: float3 = [0.0, 0.0, 0.0]
    var projectionCenter: float3 = [0.0, 0.0, 1.0]
    var projectionUp: float3 = [0.0, 1.0, 0.0]
    
    // Uniformable
    var uniformScale: float4 = float4(1.0, 1.0, 1.0, 1.0)
    var uniformPosition: float4 = float4(0.0, 0.0, 0.0, 1.0)
    var uniformRotation: float4 = float4(1.0, 1.0, 1.0, 90)
    
    var mvpMatrix:float4x4 = float4x4(diagonal: float4(1.0,1.0,1.0,1.0))
    var mvpBuffer:MTLBuffer?
    var mvpBufferId:Int = 1
    var mvpPointer: UnsafeMutablePointer<Void>?
    
    var rendererDebugGroupName = "Encode BaseRenderer"
    
    deinit {
        //TODO: release mvp
    }
    
    override init() {
        super.init()
    }
    
    func configure(view: BaseView) {
        super.configure(view)
        setPerspectiveDefaults()
        setProjectableDefaults()
        setUniformableDefaults()
        
        adjustUniformScale(view)
        prepareMvpBuffer(device!)
        prepareMvpPointer()
        
        guard preparePipelineState(view) else {
            print("Failed creating a compiled pipeline state object!")
            return
        }
    }
    
    func adjustUniformScale(view: BaseView) {
        uniformScale *= float4(1.0, Float(view.frame.width / view.frame.height), 1.0, 1.0)
    }
    
    func calcMvpMatrix(modelMatrix: float4x4) -> float4x4 {
        return calcPerspectiveMatrix() * calcProjectionMatrix() * calcUniformMatrix() * modelMatrix
    }
    
    func preparePipelineState(view: BaseView) -> Bool {
        guard let vertexProgram = shaderLibrary?.newFunctionWithName(vertexShaderName) else {
            print("Couldn't load \(vertexShaderName)")
            return false
        }
        
        guard let fragmentProgram = shaderLibrary?.newFunctionWithName(fragmentShaderName) else {
            print("Couldn't load \(fragmentShaderName)")
            return false
        }
        
        //setup render pipeline descriptor
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .BGRA8Unorm
//        MTLRenderPassDescriptor
        //setup render pipeline state
        do {
            try pipelineState = device!.newRenderPipelineStateWithDescriptor(pipelineStateDescriptor)
        } catch(let err) {
            print("Failed to create pipeline state, error \(err)")
        }
        
        return true
    }
    
    override func encode(renderEncoder: MTLRenderCommandEncoder) {
        super.encode(renderEncoder)
        renderEncoder.pushDebugGroup(rendererDebugGroupName)
        renderEncoder.setRenderPipelineState(pipelineState!)
        object!.encode(renderEncoder)
        encodeVertexBuffers(renderEncoder)
        encodeFragmentBuffers(renderEncoder)
        encodeDraw(renderEncoder)
        renderEncoder.popDebugGroup()
        renderEncoder.endEncoding()
    }
    
    func renderObjects(drawable: CAMetalDrawable, renderPassDescriptor: MTLRenderPassDescriptor, commandBuffer: MTLCommandBuffer) {
        updateMvpMatrix(object!.modelMatrix)
        updateMvpBuffer()
        let renderEncoder = commandBuffer.renderCommandEncoderWithDescriptor(renderPassDescriptor)
        self.encode(renderEncoder)
        
        commandBuffer.presentDrawable(drawable)
        
        // __block??
        //        let dispatchSemaphore: dispatch_semaphore_t = avaliableResourcesSemaphore
        
        commandBuffer.addCompletedHandler { (cmdBuffer) in
            //            dispatch_semaphore_signal(dispatchSemaphore)
        }
        commandBuffer.commit()
    }
    
    func updateLogic(timeSinceLastUpdate: CFTimeInterval) {
        object!.updateModelMatrix()
    }
    
    func encodeVertexBuffers(renderEncoder: MTLRenderCommandEncoder) {
        renderEncoder.setVertexBuffer(mvpBuffer, offset: 0, atIndex: mvpBufferId)
    }
    
    func encodeFragmentBuffers(renderEncoder: MTLRenderCommandEncoder) {
        
    }
    
    func encodeDraw(renderEncoder: MTLRenderCommandEncoder) {
        //        renderEncoder.drawPrimitives(.Triangle, vertexStart: 0, vertexCount: object!.vCount, instanceCount: 1)
    }
}
