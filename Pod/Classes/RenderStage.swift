//
//  RenderStage.swift
//  Pods
//
//  Created by David Conner on 10/7/15.
//
//

import Foundation

public typealias NodeGroupz = [String:Node]
public typealias RenderStageNodeSelect = ((NodeGroupz, [String]) -> [Node])
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
    
    func selectNodes(nodeGroup: NodeGroupz, keys: [String])
    func encode(renderer: Renderer, nodes: [Node])
    func transition(renderer: Renderer, nextRenderer: Renderer?) -> RenderEncoderTransition?
}

extension RenderStage {
    public func selectNodes(nodeGroup: NodeGroupz, keys: [String]) {
        nodes = nodeSelectBlock!(nodeGroup, keys)
    }
    
    public func encode(renderer: Renderer, nodes: [Node]) {
        encodeBlock!(renderer, nodes, nodeEncodeBlock)
    }
    
    public func transition(renderer: Renderer, nextRenderer: Renderer?) -> RenderEncoderTransition? {
        if let transitionTo = transitionBlock {
            return transitionTo(renderer, nextRenderer)
        } else {
            return renderer.transitionRenderEncoderTo(nextRenderer)
        }
    }
}

public class BaseRenderStage: RenderStage {
    public var name: String?
    public var nodes: [Node] = []
    public var nodeSelectBlock: RenderStageNodeSelect?
    public var encodeBlock: RenderStageEncodeBlock?
    public var nodeEncodeBlock: RenderStageNodeEncodeBlock?
    public var transitionBlock: RenderStageTransitionBlock?
}

