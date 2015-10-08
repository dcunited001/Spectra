//
//  RenderStage.swift
//  Pods
//
//  Created by David Conner on 10/7/15.
//
//

import Foundation

public typealias NodeGroup = [String:Node]
public typealias RenderStageNodeSelect = ((NodeGroup, [String]) -> [Node])
public typealias RenderStageNodeEncodeBlock = ((MTLRenderCommandEncoder, Node) -> Void)
public typealias RenderStageEncodeBlock = ((Renderer, [Node], RenderStageNodeEncodeBlock?) -> Void)
public typealias RenderStageTransitionBlock = ((Renderer, Renderer?) -> RenderEncoderTransition)

public protocol RenderStage: class {
    var name: String? { get set }
    var nodes: [Node] { get set }
    var nodeSelectBlock: RenderStageNodeSelect? { get set }
    var encodeBlock: RenderStageEncodeBlock? { get set }
    var nodeEncodeBlock: RenderStageNodeEncodeBlock? { get set }
    var transitionBlock: RenderStageTransitionBlock? { get set }
    
    func selectNodes(nodeGroup: NodeGroup, keys: [String])
    func encode(renderer: Renderer, nodes: [Node])
    func transition(renderer: Renderer, nextRenderer: Renderer?) -> RenderEncoderTransition?
}

extension RenderStage {
    func selectNodes(nodeGroup: NodeGroup, keys: [String]) {
        nodes = nodeSelectBlock!(nodeGroup, keys)
    }
    
    func encode(renderer: Renderer, nodes: [Node]) {
        encodeBlock!(renderer, nodes, nodeEncodeBlock)
    }
    
    func transition(renderer: Renderer, nextRenderer: Renderer?) -> RenderEncoderTransition? {
        if let transitionTo = transitionBlock {
            return transitionTo(renderer, nextRenderer)
        } else {
            return renderer.transitionRenderEncoderTo(nextRenderer)
        }
    }
}

public class BaseRenderStage: RenderStage {
    var name: String?
    var nodes: [Node] = []
    var nodeSelectBlock: RenderStageNodeSelect?
    var encodeBlock: RenderStageEncodeBlock?
    var nodeEncodeBlock: RenderStageNodeEncodeBlock?
    var transitionBlock: RenderStageTransitionBlock?
}

