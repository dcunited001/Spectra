//
//  File.swift
//  Pods
//
//  Created by David Conner on 10/12/15.
//
//

import Ono

// TODO: Schema Validation? https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/NSXML_Concepts/Articles/CreatingXMLDoc.html
// TODO: Event Driven XML programming in iOS: https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/XMLParsing/Articles/HandlingElements.html#//apple_ref/doc/uid/20002265-1001887

public enum S3DXSDType {
    case MtlEnum(name: String)
    case MtlDescriptorElement(name: String)
    case MtlDescriptorType(name: String)
//    case XSDAttribute(name: String) // do i realllly need attribute?
//    case XSDAttributeGroup(name: String)
    
    //methods to construct document selector for dependency
    
    public func findSelector() -> String {
        switch self {
        case .MtlEnum(let name):
            return "xs:simpleType[name=\(name)][mtl-enum=true]"
        case .MtlDescriptorElement(let name):
            return "xs:element[name=\(name)]"
        case .MtlDescriptorType(let name):
            return "xs:complexType[name=\(name)]"
//        case .XSDAttributeGroup(let name):
//            return "xs:attributeGroup[name=\(name)]"
        }
    }
    
    public static func getXSDNode(tag: String, name: String) -> S3DXSDType {
        switch tag {
//        case "xs:attribute": //don't need it in parseXSD()
//            return .XSDAttribute(name: name)
//        case "xs:attributeGroup":
//            return .XSDAttributeGroup(name: name)
        case "xs:element":
            return .MtlDescriptorElement(name: name)
        case "xs:complexType":
            return .MtlDescriptorType(name: name)
        default:
            // if (tag == "xs:simpleType" && mtlEnumAttr == "true")
            return .MtlEnum(name: name)
        }
    }
}

public enum S3DXSDBaseType: String {
    case XSDString = "xs:string"
    case XSDInteger = "xs:integer"
    case XSDFloat = "xs:float"
    case XSDDouble = "xs:double"
    
    public func convert(val: String) -> AnyObject {
        switch self {
        case XSDString:
            return val
        case XSDInteger:
            return Int(val)!
        case XSDFloat:
            return Float(val)!
        case XSDDouble:
            return Double(val)!
        }
    }
}

// TODO: on XSDNode's 
// - i can store attributes [String: XSDNode], 
//   - but then i run into type conflict at attribute level
// - or i can store children, but i have extra memory overhead

// TODO: evaluate protocol for S3D Node
public protocol S3DXSDNode {
    var name: String { get set }
    var type: S3DXSDType { get set }
    var attributes: [String: S3DXSDNode] { get set }
    
    init(type: S3DXSDType, elem: ONOXMLElement)
//    func apply(elem: ONOXMLElement)
}

//public class S3DXSDAttribute: S3DXSDNode {
//    public var name: String
//    public var type: S3DXSDType
//    // public var value: AnyObject
//    public var attributes: [String: S3DXSDNode] = [:]
//    
//    public required init(type: S3DXSDType, elem: ONOXMLElement) {
//        self.type = type
//        self.name = elem.valueForAttribute("name") as! String
//    }
//    
//}

public class S3DMtlEnum: S3DXSDNode {
    public var name: String
    public var type: S3DXSDType
    public var attributes: [String: S3DXSDNode] = [:]
    public var children: [String: S3DXSDNode] = [:]
    public var values: [String:Int] = [:]
    
    public required init(type: S3DXSDType, elem: ONOXMLElement) {
        self.type = type
        self.name = elem.valueForAttribute("name") as! String
        parseEnumValues(elem)
    }
    
    public func parseEnumValues(elem: ONOXMLElement) {
        values = [:]
        let valuesSelector = "xs:restriction > xs:enumeration"
        elem.enumerateElementsWithCSS(valuesSelector) { (el, idx, stop) -> Void in
            let val = el.valueForAttribute("id") as! String
            let key = el.valueForAttribute("value") as! String
            self.values[key] = Int(val)
        }
    }
}

public class S3DMtlDescriptorElement: S3DXSDNode {
    public var name: String
    public var type: S3DXSDType
    public var attributes: [String: S3DXSDNode] = [:]
    public var descriptorTypeMap: [String: String] = [:]
    
    public required init(type: S3DXSDType, elem: ONOXMLElement) {
        self.type = type
        self.name = elem.valueForAttribute("name") as! String
    }
}

public class S3DMtlDescriptorType: S3DXSDNode {
    public var name: String
    public var type: S3DXSDType
    public var attributes: [String: S3DXSDNode] = [:]
    
    public required init(type: S3DXSDType, elem: ONOXMLElement) {
        self.type = type
        self.name = elem.valueForAttribute("name") as! String
    }
}

public class S3DXSD {
    public var xml: ONOXMLDocument?
    public var enumTypes: [String:S3DMtlEnum] = [:]
    public var descriptorTypes: [String:S3DMtlDescriptorType] = [:]
    public var descriptorElements: [String:S3DMtlDescriptorElement] = [:]
    
    public init(data: NSData!) {
        xml = try! ONOXMLDocument(data: data)
        resetNodes()
    }
    
    public class func readXSD(filename: String) -> NSData {
        let podBundle = NSBundle(forClass: S3DXSD.self)
        let bundleUrl = podBundle.URLForResource("Spectra", withExtension: "bundle")
        let bundle = NSBundle(URL: bundleUrl!)
        let path = bundle!.pathForResource("Spectra3D", ofType: "xsd")
        let data = NSData(contentsOfFile: path!)
        return data!
    }
    
    //    public class func readXSDString(string: String) -> NSData {
    //
    //    }
    
    public func resetNodes() {
        enumTypes = [:]
        descriptorTypes = [:]
        descriptorElements = [:]
    }
    
    public func parseXSD() {
        for (elem) in xml!.rootElement.children {
            var el = elem as! ONOXMLElement
            let name = el.valueForAttribute("name") as! String
            let mtlEnumAttr = elem.valueForAttribute("mtl-enum") as? String // TODO: cast as bool
            
            let nodeType = S3DXSDType.getXSDNode(el.tag, name: name)
            if let node = getNode(nodeType) {
            } else {
                let node = createNode(nodeType, elem: el)
            }
            
            // - check for node definition already
            //            let nodeDefinition = getNodeDefinition(el)
            
            // - if it exists, skip to next node
            //            if (!nodeExists(parsedNodes, nodeDefinition: nodeDefinition)) {
            //                loadNode(parsedNodes, elem: el, nodeDefinition: nodeDefinition)
            //            }
            
            // - if it doesn't, parse together a new one and assemble it's attributes
            //   - if one of those attributes has an unknown type dependency
            //     - break out and load that specific one and it's dependencies recursively
            // - when all root nodes are done, all type definitions should have been read in
            //            return nodes
        }
    }
    
    public func getNode(nodeType: S3DXSDType) -> S3DXSDNode? {
        switch nodeType {
        case .MtlEnum(let name):
            return enumTypes[name]
        case .MtlDescriptorElement(let name):
            return descriptorElements[name]
        case .MtlDescriptorType(let name):
            return descriptorTypes[name]
//        case .XSDAttributeGroup(let name):
//            return attributeGroups[name]
        }
    }
    
    public func createNode(nodeType: S3DXSDType, elem: ONOXMLElement) -> S3DXSDNode {
        switch nodeType {
        case .MtlEnum:
            return S3DMtlEnum(type: nodeType, elem: elem)
        case .MtlDescriptorElement:
            return S3DMtlDescriptorElement(type: nodeType, elem: elem)
        case .MtlDescriptorType:
            return S3DMtlDescriptorType(type: nodeType, elem: elem)
//        case .XSDAttributeGroup:
//            return S3DXSDAttributeGroup(type: nodeType, elem: elem)
        }
    }
    
    //    public func getNodeDefinition(elem: ONOXMLElement) -> [String:String] {
    //        let tag = elem.tag
    //        let name = elem.valueForAttribute("name") as! String
    //        let typeAttr = elem.valueForAttribute("type") as! String
    //        let mtlEnumAttr = elem.valueForAttribute("mtl-enum") as? String // TODO: cast as bool
    //
    //        var type: S3DXSDType = .MtlDescriptorType
    //        if (tag == "xs:element") {
    //            type = .MtlDescriptorElement
    //        } else {
    //            if (tag == "xs:simpleType" && mtlEnumAttr == "true") {
    //                type = .MtlEnum
    //            } else {
    //                if (tag == "xs:attributeGroup") {
    //                    type = .MtlAttributeGroup
    //                }
    //            }
    //        }
    //
    //        return ["name": name, "type": type.rawValue]
    //    }
    
    //    public func loadNode(var nodes: [S3DXSDType:[String:AnyObject]], elem: ONOXMLElement, nodeDefinition: [String: String]) -> [S3DXSDType:[String:AnyObject]] {
    //
    //        // search for the specific node
    //        // - load it, attach them to the nodesIn function
    //        // - and recursively pass unknown node definitions to next level
    //
    //        // TODO: how to load attributes?
    //
    //        let nodeType = S3DXSDType(rawValue: nodeDefinition["type"]!)!
    //        switch nodeType {
    //        case .MtlEnum:
    //            let newNode = S3DMtlEnum(elem: elem)
    //            nodes[nodeType]![nodeDefinition["name"]!] = newNode
    //            break
    //        case .MtlAttributeGroup:
    //            let newNode = S3DMtlAttributeGroup(elem: elem)
    //            nodes[nodeType]![nodeDefinition["name"]!] = newNode
    //            break
    //        case .MtlDescriptorElement:
    //            break
    //        case .MtlDescriptorType:
    //            break
    //        }
    //
    //        return nodes
    //    }
    
    //    public func nodeExists(parsedNodes: [S3DXSDType:[String:AnyObject]], nodeDefinition: [String:String]) -> Bool {
    //        let type = S3DXSDType(rawValue: nodeDefinition["type"]!)!
    //        let name = nodeDefinition["name"]!
    //        if let _ = parsedNodes[type]![name] {
    //            return true
    //        } else {
    //            return false
    //        }
    //    }
    //
    //    public func findNode(nodeDefinition: [String:String]) -> ONOXMLElement? {
    //        // - construct selector to find element
    //        // - return it
    //        return xml!.rootElement
    //    }
    //
    //    public func parseEnumTypes() {
    //        let enumTypesSelector = "xs:simpleType[mtl-enum=true]"
    //        xml!.enumerateElementsWithCSS(enumTypesSelector) { (elem, idx, stop) -> Void in
    //            let enumType = S3DMtlEnum(elem: elem)
    //            self.enumTypes[enumType.name] = enumType
    //        }
    //    }
    //
    //    public func parseAttributeGroups() {
    //        let attributeGroupsSelector = "xs:attributeGroup[name]"
    //        xml!.enumerateElementsWithCSS(attributeGroupsSelector) { (elem, idx, stop) -> Void in
    //            let attrGroup = S3DMtlAttributeGroup(elem: elem)
    //            self.attributeGroups[attrGroup.name] = attrGroup
    //        }
    //    }
    //
    //    public func parseDescriptorTypes() {
    //        // TODO: force XSD to process in stages by using multiple complexTypesSelector's
    //        let complexTypesSelector = "xs:complexType"
    //        xml!.enumerateElementsWithCSS(complexTypesSelector) { (elem, idx, stop) -> Void in
    //            let descriptorType = S3DMtlDescriptorType(elem: elem)
    //            self.descriptorTypes[descriptorType.name] = descriptorType
    //        }
    //    }
}
