//
//  SpectraView.swift
//  Spectra
//
//  Created by David Conner on 9/27/15.
//  Copyright © 2015 Spectra. All rights reserved.
//

import MetalKit

// create a notion of a scene renderer
// GOAL: TOTALLY abstract game state from rendering

//TODO: differentiate SpectraBaseView for ios & osx
// - using extension & available keywords?
// - need to override layoutSubviews() on iOS
// - need to override setFrameSize() on OSX
// - or let the user of the lib override this?

public protocol RenderDelegate: class {
    var pipelineStateMap: RenderPipelineStateMap { get set }
    var depthStencilStateMap: DepthStencilStateMap { get set }
    var rendererMap: RendererMap { get set }
    
    func renderObjects(drawable: CAMetalDrawable, renderPassDescriptor: MTLRenderPassDescriptor, commandBuffer: MTLCommandBuffer, inflightResourcesIndex: Int)
}

public protocol UpdateDelegate: class {
    func updateObjects(timeSinceLastUpdate: CFTimeInterval, inflightResourcesIndex: Int)
}

//TODO: MUST IMPLEMENT NSCODER & deinit to dealloc
public class BaseView: MTKView {
    public var defaultLibrary: MTLLibrary!
    public var commandQueue: MTLCommandQueue!
    public var renderPassDescriptor: MTLRenderPassDescriptor?
    public var inflightResources: InflightResourceManager
    
    public var startTime: CFAbsoluteTime!
    public var lastFrameStart: CFAbsoluteTime!
    public var thisFrameStart: CFAbsoluteTime!
    
    public weak var renderDelegate: RenderDelegate?
    public weak var updateDelegate: UpdateDelegate?
    
    override public init(frame frameRect:CGRect, device:MTLDevice?) {
        inflightResources = InflightResourceManager()
        super.init(frame: frameRect, device: device)
        
        configureGraphics()
    }
    
    required public init(coder: NSCoder) {
        inflightResources = InflightResourceManager()
        super.init(coder: coder)
        
        configureGraphics()
    }
    
    public func configureGraphics() {
        mtkViewDefaults()
        beforeSetupMetal()
        setupMetal()
        afterSetupMetal()
        
        // move to scene renderer?
        // setupRenderPipeline()
    }
    
    public func beforeSetupMetal() {
        //override in subclass
    }
    
    public func afterSetupMetal() {
        //override in subclass
    }
    
    public func mtkViewDefaults() {
        //TODO: framebufferOnly might be why particleLab failed on OSX!
        framebufferOnly = false
        preferredFramesPerSecond = 60
        colorPixelFormat = MTLPixelFormat.BGRA8Unorm
        sampleCount = 1
    }
    
    public func metalUnavailable() {
        //override in subclass
    }
    
    public func setupMetal() {
        guard let device = MTLCreateSystemDefaultDevice() else {
            self.metalUnavailable()
            return
        }
        
        self.device = device
        defaultLibrary = device.newDefaultLibrary()
        commandQueue = device.newCommandQueue()
    }
    
    public func render() {
        inflightResources.wait()
        let cmdBuffer = commandQueue.commandBuffer()
        
        cmdBuffer.addCompletedHandler { (cmdBuffer) in
            self.inflightResources.next()
        }
        
        guard let drawable = currentDrawable else
        {
            Swift.print("currentDrawable returned nil")
            return
        }
        
        //N.B. the app does not necessarily need to use currentRenderPassDescriptor
        var renderPassDescriptor = setupRenderPassDescriptor(drawable, renderPassDescriptor: currentRenderPassDescriptor!)
        self.renderDelegate?.renderObjects(drawable, renderPassDescriptor: renderPassDescriptor, commandBuffer: cmdBuffer, inflightResourcesIndex: inflightResources.index)
        
        cmdBuffer.presentDrawable(drawable)
        cmdBuffer.commit()
    }
    
    public func setupRenderPipeline() {
        //move to scene renderer?
    }
    
    public func setupRenderPassDescriptor(drawable: CAMetalDrawable, renderPassDescriptor: MTLRenderPassDescriptor) -> MTLRenderPassDescriptor {
        return renderPassDescriptor
    }
    
    public func reshape(view:MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    override public func drawRect(dirtyRect: CGRect) {
        lastFrameStart = thisFrameStart
        thisFrameStart = CFAbsoluteTimeGetCurrent()
        self.updateDelegate?.updateObjects(CFTimeInterval(thisFrameStart - lastFrameStart), inflightResourcesIndex: inflightResources.index)
        
        autoreleasepool { () -> () in
            self.render()
        }
    }
}