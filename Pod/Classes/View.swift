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

protocol ViewDelegate: class {
    func updateLogic(timeSinceLastUpdate: CFTimeInterval)
    func renderObjects(drawable: CAMetalDrawable, renderPassDescriptor: MTLRenderPassDescriptor, commandBuffer: MTLCommandBuffer)
    func encode(renderEncoder: MTLRenderCommandEncoder)
}

//TODO: MUST IMPLEMENT NSCODER & deinit to dealloc
class BaseView: MTKView {
    var commandBufferProvider: CommandBufferProvider?
    var commandQueue: MTLCommandQueue!
    var defaultLibrary: MTLLibrary!
    
    var startTime: CFAbsoluteTime!
    var lastFrameStart: CFAbsoluteTime!
    var thisFrameStart: CFAbsoluteTime!
    
    weak var metalViewDelegate: ViewDelegate?
    
    override init(frame frameRect:CGRect, device:MTLDevice?) {
        super.init(frame: frameRect, device: device)
        //TODO: framebufferOnly might be why particleLab failed on OSX!
        framebufferOnly = false
        preferredFramesPerSecond = 60
        
        beforeSetupMetal()
        setupMetal()
        afterSetupMetal()
        
        //move to scene renderer?
        //setupRenderPipeline()
    }
    
    required init(coder: NSCoder) {
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
        commandBufferProvider = CommandBufferProvider(commandQueue: commandQueue)
    }
    
    func render() {
        //move to scene renderer?
    }
    
    func setupRenderPipeline() {
        //move to scene renderer?
    }
    
    var renderPassDescriptor: MTLRenderPassDescriptor?
    func setupRenderPassDescriptor() {
        //move to scene renderer?
    }
    
    func reshape(view:MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    override func drawRect(dirtyRect: CGRect) {
        lastFrameStart = thisFrameStart
        thisFrameStart = CFAbsoluteTimeGetCurrent()
        self.metalViewDelegate?.updateLogic(CFTimeInterval(thisFrameStart - lastFrameStart))
        
        autoreleasepool { () -> () in
            self.render()
        }
    }
}