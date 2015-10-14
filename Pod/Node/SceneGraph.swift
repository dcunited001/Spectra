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
    public var s3dDefinitions: S3DXSD
    public var xml: ONOXMLDocument?
    
    let nodeGenAttr = "spectra-node-gen"
    let nodeRefAttr = "spectra-node-ref"
    
    public init(xmlData: NSData) {
        let xmlData = S3DXSD.readXSD("Spectra3D")
        self.s3dDefinitions = S3DXSD(data: xmlData)
    }
    
    public func getS3DDefinitions() {
        // make s3dDefinitions optional?
        
    }
    
    public func createGeneratedNodes(generatorMap: [String:NodeGenerator], var nodeMap: SceneNodeMap) -> SceneNodeMap {
        xml!.enumerateElementsWithCSS("mesh[\(nodeGenAttr)]", block: { (elem) -> Void in
            let nodeGenName = elem.valueForAttribute(self.nodeGenAttr) as! String
            let nodeId = elem.valueForAttribute("id") as! String
            nodeMap[nodeId] = generatorMap[nodeGenName]!.generate()
        })
        
        return nodeMap
    }
    
    public func createRefNodes(var nodeMap: SceneNodeMap) -> SceneNodeMap {
        xml!.enumerateElementsWithCSS("mesh[\(nodeRefAttr)]", block: { (elem) -> Void in
            let nodeRefName = elem.valueForAttribute(self.nodeRefAttr) as! String
            let nodeId = elem.valueForAttribute("id") as! String
            nodeMap[nodeId] = nodeMap[nodeRefName]
        })
        
        return nodeMap
    }
}