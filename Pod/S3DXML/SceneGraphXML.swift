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
import simd

public class SceneGraphXML {
    public var xml: ONOXMLDocument?
    
    public init(data: NSData) {
        xml = try! ONOXMLDocument(data: data)
    }
    
    // TODO: methods to specify load order?
    // - e.g. what if you want to declare nodes/meshs in XML
    //   - but then load all/some of their data using generators or whatever?
    
    public func parse(sceneGraph: SceneGraph, options: [String: AnyObject] = [:]) -> SceneGraph {
        for child in xml!.rootElement.children {            
            let elem = child as! ONOXMLElement
            let tag = elem.tag
            let key = elem.valueForAttribute("key") as? String
            
            switch tag {
            case "view":
                sceneGraph.views[key!] = sceneGraph.views[key!] ?? SGXMLViewNode().parse(sceneGraph, elem: elem)
            case "perspective":
                sceneGraph.perspectives[key!] = sceneGraph.perspectives[key!] ?? SGXMLPerspectiveNode().parse(sceneGraph, elem: elem)
            case "camera":
                sceneGraph.cameras[key!] = sceneGraph.cameras[key!] ?? SGXMLCameraNode().parse(sceneGraph, elem: elem)
            default:
                break
            }
        }
        
        return sceneGraph
    }
    
    public class func readXML(bundle: NSBundle, filename: String, bundleResourceName: String? = nil) -> NSData {
        
        var resourceBundle: NSBundle = bundle
        if let resourceName = bundleResourceName {
            let bundleURL = bundle.URLForResource(resourceName, withExtension: "bundle")
            resourceBundle = NSBundle(URL: bundleURL!)!
        }
        
        let path = resourceBundle.pathForResource(filename, ofType: "xml")
        let data = NSData(contentsOfFile: path!)
        return data!
    }
}

public protocol SGXMLNodeParser {
    typealias NodeType
    
    func parse(sceneGraph: SceneGraph, elem: ONOXMLElement, options: [String: AnyObject]) -> NodeType
}

public class SGXMLSimd {
    public static func parseDoubles(str: String) -> [Double] {
        let valStrs = str.characters.split { $0 == " " }.map(String.init)
        return valStrs.map() { Double($0)! }
    }
    
    public static func parseInts(str: String) -> [Int] {
        let valStrs = str.characters.split { $0 == " " }.map(String.init)
        return valStrs.map() { Int($0)! }
    }
    
    public static func parseInt32s(str: String) -> [Int32] {
        let valStrs = str.characters.split { $0 == " " }.map(String.init)
        return valStrs.map() { Int32($0)! }
    }
    
    public static func parseFloats(str: String) -> [Float] {
        let valStrs = str.characters.split { $0 == " " }.map(String.init)
        return valStrs.map() { Float($0)! }
    }
    
    public static func parseFloat4(str: String) -> float4 {
        return float4(parseFloats(str))
    }
    
    public static func parseInt4(str: String) -> int4 {
        return int4(parseInt32s(str))
    }
}


public class SGXMLUniformsNode: SGXMLNodeParser {
    public typealias NodeType = Uniformable
    
    public func parse(sceneGraph: SceneGraph, elem: ONOXMLElement, options: [String : AnyObject] = [:]) -> NodeType {
        let node = BaseUniforms()
        
        if let pos = elem.valueForAttribute("pos") as? String {
            node.uniformPosition = SGXMLSimd.parseFloat4(pos)
        }
        
        if let rotation = elem.valueForAttribute("rotation") as? String {
            node.uniformRotation = SGXMLSimd.parseFloat4(rotation)
        }
        
        if let scale = elem.valueForAttribute("scale") as? String {
            node.uniformScale = SGXMLSimd.parseFloat4(scale)
        }
        
        return node
    }
}

// TODO: how to instantiate protocol types without explicitly referring to the implementation of the protocol??
// E.G. Uniforms/BaseUniforms
public class SGXMLViewNode: SGXMLNodeParser {
    public typealias NodeType = WorldView
    
    public func parse(sceneGraph: SceneGraph, elem: ONOXMLElement, options: [String: AnyObject] = [:]) -> NodeType {
        
        var node: NodeType
        if let nodeType = elem.valueForAttribute("type") as? String {
            if let monad = sceneGraph.getViewMonad(nodeType) {
                node = monad()
            } else {
                node = BaseWorldView()
            }
        } else {
            node = BaseWorldView()
        }
        
        if let uniforms = elem.firstChildWithTag("uniforms") {
            node.uniforms = SGXMLUniformsNode().parse(sceneGraph, elem: uniforms)
        }
        
        return node
    }
}

public class SGXMLCameraNode: SGXMLNodeParser {
    public typealias NodeType = Camable
    
    public func parse(sceneGraph: SceneGraph, elem: ONOXMLElement, options: [String : AnyObject] = [:]) -> NodeType {
        
        var node: NodeType
        if let nodeType = elem.valueForAttribute("type") as? String {
            if let monad = sceneGraph.getCameraMonad(nodeType) {
                node = monad()
            } else {
                node = BaseCamera()
            }
        } else {
            node = BaseCamera()
        }
        
        if let eye = elem.valueForAttribute("eye") as? String {
            node.camEye = SGXMLSimd.parseFloat4(eye)
        }
        
        if let center = elem.valueForAttribute("center") as? String {
            node.camCenter = SGXMLSimd.parseFloat4(center)
        }
        
        if let up = elem.valueForAttribute("up") as? String {
            node.camUp = SGXMLSimd.parseFloat4(up)
        }
        
        return node
    }
}

public class SGXMLPerspectiveNode: SGXMLNodeParser {
    public typealias NodeType = Perspectable
    
    public func parse(sceneGraph: SceneGraph, elem: ONOXMLElement, options: [String : AnyObject] = [:]) -> NodeType {
        var node = BasePerspectable()
        
        if let type = elem.valueForAttribute("type") as? String {
            node.perspectiveType = type
        }
        
        let argsSelector = "perspective-arg"
        elem.enumerateElementsWithCSS(argsSelector) {(el, idx, stop) in
            let argName = el.valueForAttribute("name") as! String
            let argValue = el.valueForAttribute("value") as! String
            
            node.perspectiveArgs[argName] = Float(argValue)
        }
        
        return node
    }
}

public class SGXMLMeshGeneratorNode: SGXMLNodeParser {
    public typealias NodeType = MeshGenerator
    
    public func parse(sceneGraph: SceneGraph, elem: ONOXMLElement, options: [String : AnyObject]) -> NodeType {
        
        var node: NodeType
        var meshGenArgs: [String: String] = [:]
        let argsSelector = "mesh-generator-arg"
        elem.enumerateElementsWithCSS(argsSelector) {(el, idx, stop) in
            let argName = el.valueForAttribute("name") as! String
            let argValue = el.valueForAttribute("value") as! String
            meshGenArgs[argName] = argValue
        }
        
        if let nodeType = elem.valueForAttribute("type") as? String {
            if let monad = sceneGraph.getMeshGeneratorMonad(nodeType) {
                node = monad(meshGenArgs)
            } else {
                node = BasicTriangleGenerator(args: meshGenArgs)
            }
        } else {
            node = BasicTriangleGenerator(args: meshGenArgs)
        }
        
        return node
    }
}

public class SGXMLMeshNode: SGXMLNodeParser {
    public typealias NodeType = Mesh
    
    public func parse(sceneGraph: SceneGraph, elem: ONOXMLElement, options: [String : AnyObject]) -> NodeType {
        //TODO: mesh monads for each mesh type?
        var node: Mesh = BaseMesh()
        
        // i'd really rather lazily evaluate the node
        
        
        return node
    }
}
