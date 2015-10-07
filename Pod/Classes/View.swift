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

protocol RenderDelegate: class {
    var pipelineStateMap: [String:MTLRenderPipelineState] { get set }
    var rendererMap: [String:Renderer] { get set }
    
    func renderObjects(drawable: CAMetalDrawable, renderPassDescriptor: MTLRenderPassDescriptor, commandBuffer: MTLCommandBuffer, inflightResourcesIndex: Int)
}

protocol UpdateDelegate: class {
    func updateObjects(timeSinceLastUpdate: CFTimeInterval, inflightResourcesIndex: Int)
}

//TODO: MUST IMPLEMENT NSCODER & deinit to dealloc
class BaseView: MTKView {
    var defaultLibrary: MTLLibrary!
    var commandQueue: MTLCommandQueue!
    var renderPassDescriptor: MTLRenderPassDescriptor?
    var inflightResources: InflightResourceManager
    
    var startTime: CFAbsoluteTime!
    var lastFrameStart: CFAbsoluteTime!
    var thisFrameStart: CFAbsoluteTime!
    
    weak var renderDelegate: RenderDelegate?
    weak var updateDelegate: UpdateDelegate?
    
    override init(frame frameRect:CGRect, device:MTLDevice?) {
        inflightResources = InflightResourceManager()
        super.init(frame: frameRect, device: device)
        //TODO: framebufferOnly might be why particleLab failed on OSX!
        framebufferOnly = false
        preferredFramesPerSecond = 60
        
        beforeSetupMetal()
        setupMetal()
        afterSetupMetal()
        
        // move to scene renderer?
        // setupRenderPipeline()
    }
    
    required init(coder: NSCoder) {
        inflightResources = InflightResourceManager()
        super.init(coder: coder)
        //        fatalError("init(coder:) has not been implemented")
    }
    
    func beforeSetupMetal() {
        //override in subclass
    }
    
    func afterSetupMetal() {
        //override in subclass
    }
    
    func metalUnavailable() {
        //override in subclass
    }
    
    func setupMetal() {
        guard let device = MTLCreateSystemDefaultDevice() else {
            self.metalUnavailable()
            return
        }
        
        self.device = device
        defaultLibrary = device.newDefaultLibrary()
        commandQueue = device.newCommandQueue()
    }
    
    func render() {
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
    
    func setupRenderPipeline() {
        //move to scene renderer?
    }
    
    func setupRenderPassDescriptor(drawable: CAMetalDrawable, renderPassDescriptor: MTLRenderPassDescriptor) -> MTLRenderPassDescriptor {
        return renderPassDescriptor
    }
    
    func reshape(view:MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    override func drawRect(dirtyRect: CGRect) {
        lastFrameStart = thisFrameStart
        thisFrameStart = CFAbsoluteTimeGetCurrent()
        self.updateDelegate?.updateObjects(CFTimeInterval(thisFrameStart - lastFrameStart), inflightResourcesIndex: inflightResources.index)
        
        autoreleasepool { () -> () in
            self.render()
        }
    }
}