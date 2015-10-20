//
//  SceneGraphXML.swift
//  Pods
//
//  Created by David Conner on 10/19/15.
//
//

import Foundation
import Ono
import Metal

public class SceneGraphXML {
    public var xml: ONOXMLDocument?
    
    public init(data: NSData) {
        xml = try! ONOXMLDocument(data: data)
    }
    
    public func parse(sceneGraph: SceneGraph) -> SceneGraph {
        for child in xml!.rootElement.children {
            
        }
    }
}