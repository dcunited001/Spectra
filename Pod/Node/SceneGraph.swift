//
//  SceneGraph.swift
//  Pods
//
//  Created by David Conner on 10/11/15.
//
//

// X3D documentation: http://www.web3d.org/specifications/X3dSchemaDocumentation3.3/x3d-3.3.html
// X3D Cube Example: view-source:http://www.web3d.org/x3d/content/examples/Basic/DistributedInteractiveSimulation/TestCubeCanonical.xml
// X3Dom efficient Binary Meshes: http://www.web3d.org/sites/default/files/presentations/Efficient%20Binary%20Meshes%20in%20X3DOM%20Refined/x3dom_Efficient-Binary-Meshes_behr.pdf
// X3Dom docs: http://doc.x3dom.org/
// Xml3D basics: https://github.com/xml3d/xml3d.js/wiki/The-Basics-of-XML3D

import Ono

public class MeshData {}
public class MeshDataMap {}
public class NodeGroup {}

public class SceneGraph {
    
    let nodeGenAttr = "spectra-node-gen"
    let nodeRefAttr = "spectra-node-ref"
    
    public var perspectives: [String: Perspectable] = [:]
    public var views: [String: WorldView] = [:]
    public var cameras: [String: Camable] = [:]

    public var nodes: [String: Node] = [:]
    public var nodeGroups: [String: NodeGroup] = [:]
    public var meshes: [String: Mesh] = [:]
    public var meshData: [String: MeshData] = [:]
    public var meshDataMap: [String: MeshDataMap] = [:]
    public var meshGenerators: [String: MeshGenerator] = [:]
    
    private var viewMonads: [String: (() -> WorldView)] = [:] //final?
    private var cameraMonads: [String: (() -> Camable)] = [:] //final?
    private var meshGeneratorMonads: [String: (([String: String]) -> MeshGenerator)] = [:]
    
    // resources
    // - buffers? (encodable data or buffer pools)
    // - inputs?
    // - textures?
    
    public init() {
        setDefaultMeshGeneratorMonads()
    }
    
//    public func loadXML(data: NSData) {
//        //TODO: scene graph data from xml into objects
//    }
    
//    public func createGeneratedNodes(generatorMap: [String:NodeGenerator], var nodeMap: SceneNodeMap) -> SceneNodeMap {
//        xml!.enumerateElementsWithCSS("mesh[\(nodeGenAttr)]", block: { (elem) -> Void in
//            let nodeGenName = elem.valueForAttribute(self.nodeGenAttr) as! String
//            let nodeId = elem.valueForAttribute("id") as! String
//            nodeMap[nodeId] = generatorMap[nodeGenName]!.generate()
//        })
//        
//        return nodeMap
//    }
//    
//    public func createRefNodes(var nodeMap: SceneNodeMap) -> SceneNodeMap {
//        xml!.enumerateElementsWithCSS("mesh[\(nodeRefAttr)]", block: { (elem) -> Void in
//            let nodeRefName = elem.valueForAttribute(self.nodeRefAttr) as! String
//            let nodeId = elem.valueForAttribute("id") as! String
//            nodeMap[nodeId] = nodeMap[nodeRefName]
//        })
//        
//        return nodeMap
//    }
    
    //TODO: going to try out these protocol monad lists on a few types
    // - so more complicated types can be instantiated via xml
    // - or (for view/camera) i may just want to follow the perspectiveArgs example
    public func registerViewMonad(key: String, monad: (() -> WorldView)) {
        viewMonads[key] = monad
    }
    
    public func getViewMonad(key: String) -> (() -> WorldView)? {
        return viewMonads[key]
    }
    
    public func registerCameraMonad(key: String, monad: (() -> Camable)) {
        cameraMonads[key] = monad
    }
    
    public func getCameraMonad(key: String) -> (() -> Camable)? {
        return cameraMonads[key]
    }
    
    public func registerMeshGeneratorMonad(key: String, monad: (([String: String]) -> MeshGenerator)) {
        meshGeneratorMonads[key] = monad
    }
    
    public func getMeshGeneratorMonad(key: String) -> (([String: String]) -> MeshGenerator)? {
        return meshGeneratorMonads[key]
    }
    
    private func setDefaultMeshGeneratorMonads() {
        registerMeshGeneratorMonad("basic_triangle") { (args) in
            return BasicTriangleGenerator(args: args)
        }
        registerMeshGeneratorMonad("quad") { (args) in
            return QuadGenerator(args: args)
        }
        registerMeshGeneratorMonad("cube") { (args) in
            return CubeGenerator(args: args)
        }
        registerMeshGeneratorMonad("cube") { (args) in
            return TetrahedronGenerator(args: args)
        }
        registerMeshGeneratorMonad("cube") { (args) in
            return OctahedronGenerator(args: args)
        }
    }
}