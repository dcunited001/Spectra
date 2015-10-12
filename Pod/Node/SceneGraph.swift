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

public class SceneGraph {
    public var xml: ONOXMLDocument?
    
    public init(xmlData: NSData) {
        xml = try! ONOXMLDocument(data: xmlData)
    }
    
    
    public func createNodeWithGenerator(generatorMap: [String:NodeGenerator], generatorKey: String) -> Node {
        return generatorMap[generatorKey]!.generate()
    }
    
    public func createGeneratedNodes(generatorMap: [String:NodeGenerator], nodeMap: SceneNodeMap) -> SceneNodeMap {
        return nodeMap
    }
    
    public func createDependentNodes(nodeMap: SceneNodeMap) -> SceneNodeMap {
        return nodeMap
    }
}
