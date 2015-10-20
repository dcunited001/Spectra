//
//  WorldView.swift
//  Pods
//
//  Created by David Conner on 10/20/15.
//
//

public protocol WorldView: class {
    var uniforms: Uniformable { get set }
}

public class BaseWorldView: WorldView {
    public var uniforms: Uniformable
    
    public init() {
        uniforms = BaseUniforms()
    }
}
