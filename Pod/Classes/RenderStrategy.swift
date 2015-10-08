//
//  RenderStrategy.swift
//  Pods
//
//  Created by David Conner on 10/7/15.
//
//

import Foundation

public protocol RenderStrategy: class {
    var currentRenderStage: Int { get set }
    var renderStages: [RenderStage] { get set }
}

extension RenderStrategy {
    func execRenderStage(commandBuffer: MTLCommandBuffer, renderPassDescriptor: MTLRenderPassDescriptor, renderEncoder: MTLRenderCommandEncoder, renderStage: RenderStage, renderer: Renderer, nextRenderer: Renderer?) {
        
        var nextRenderEncoder: MTLRenderCommandEncoder?
        if let renderEncoderTransition = renderStage.transition(renderer, nextRenderer: nextRenderer) {
            nextRenderEncoder = renderEncoderTransition(renderEncoder)
        } else {
            nextRenderEncoder = (renderer.defaultRenderEncoderTransition())(commandBuffer, renderPassDescriptor)
        }
    }
}

public class BaseRenderStrategy: RenderStrategy {
    var currentRenderStage: Int = 0
    var renderStages: [RenderStage] = []
}
