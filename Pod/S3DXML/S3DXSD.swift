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

public class S3DXSD {
    public var xml: ONOXMLDocument?
    public var attributeGroups: [String:S3DAttributeGroup] = [:]
    public var enumTypes: [String:S3DMtlEnum] = [:]
    public var descriptorTypes: [String:S3DMtlDescriptorType] = [:]
    public var descriptorElements: [String:S3DMtlDescriptorElement] = [:]
    
    public init(data: NSData!) {
        xml = try! ONOXMLDocument(data: data)
    }
    
    public func parseEnumTypes() {
        let enumTypesSelector = "xs:simpleType[mtl-enum=true]"
        xml!.enumerateElementsWithCSS(enumTypesSelector) { (elem, idx, stop) -> Void in
            let enumName = elem.valueForAttribute("name") as! String
            let enumType = S3DMtlEnum(name: enumName, elem: elem)
            self.enumTypes[enumName] = enumType
        }
    }
    
    public func parseAttributeGroups() {
        let attributeGroupsSelector = "xs:attributeGroup"
        xml!.enumerateElementsWithCSS(attributeGroupsSelector) { (elem, idx, stop) -> Void in
            let groupName = elem.valueForAttribute("name") as! String
            let attrGroup = S3DAttributeGroup(name: groupName, elem: elem)
            self.attributeGroups[groupName] = attrGroup
        }
    }
    
    public func parseDescriptorTypes() {
        // TODO: force XSD to process in stages by using multiple complexTypesSelector's
        let complexTypesSelector = "xs:complexType"
        xml!.enumerateElementsWithCSS(complexTypesSelector) { (elem, idx, stop) -> Void in
            let descriptorName = elem.valueForAttribute("name") as! String
            let descriptorType = S3DMtlDescriptorType(name: descriptorName, elem: elem)
            self.descriptorTypes[descriptorName] = descriptorType
        }
    }
}

public class S3DAttributeGroup {
    var name: String
    var attributes: [String: String] = [:] // name, type ... needs more?
    
    public init(name: String, elem: ONOXMLElement) {
        self.name = name
        parseGroup(elem)
    }
    
    public func parseGroup(elem: ONOXMLElement) {
        attributes = [:]
        let attributesSelector = "xs:attribute"
        elem.enumerateElementsWithCSS(attributesSelector) { (el, idx, stop) -> Void in
            let attrName = el.valueForAttribute("name") as! String
            let attrType = el.valueForAttribute("type") as! String
            self.attributes[attrName] = attrType
        }
    }
    
    public func applyGroup() {
        
    }
}

public class S3DMtlEnum {
    public var name: String
    public var values: [String:Int] = [:]
    
    public init(name: String, elem: ONOXMLElement) {
        self.name = name
    }
    
    public func parseEnumValues(elem: ONOXMLElement) {
        let valuesSelector = "xs:restriction > xs:enumeration"
        elem.enumerateElementsWithCSS(valuesSelector) { (el,idx, stop) -> Void in
            let val = el.valueForAttribute("id") as! Int
            let key = el.valueForAttribute("value") as! String
            self.values[key] = val
        }
    }
}

public class S3DMtlDescriptorElement {
    public var name: String
    public var descriptorTypeMap: [String: String] = [:]
    
    public init(name:String) {
        self.name = name
    }
}

public class S3DMtlDescriptorType {
    public var name: String
    
    public init(name: String, elem: ONOXMLElement) {
        self.name = name
    }
}
