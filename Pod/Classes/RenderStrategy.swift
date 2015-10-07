//
//  RenderStrategy.swift
//  Pods
//
//  Created by David Conner on 10/7/15.
//
//

import Foundation

protocol RenderStrategy {
    var currentRenderStage: Int { get set }
    var renderStages: [RenderStage] { get set }
    
}

extension RenderStrategy {
    
}

class BaseRenderStrategy: RenderStrategy {
    var currentRenderStage: Int = 0
    var renderStages: [RenderStage] = []
}