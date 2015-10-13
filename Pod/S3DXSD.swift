//
//  File.swift
//  Pods
//
//  Created by David Conner on 10/12/15.
//
//

import Ono

public class S3DXSD {
    public var xml: ONOXMLDocument?
    public var attributeGroups: [String:S3DAttributeGroup] = [:]
    public var enumTypes: [String:S3DMtlEnum] = [:]
    public var descriptorTypes: [String:S3DMtlDescriptor] = [:]
    
    public init(data: NSData!) {
        //parse xml
    }
    
    public func parseEnumTypes() {
        let enumTypesSelector = "xs:simpleType[mtl-enum=true]"
        xml?.enumerateElementsWithCSS(enumTypesSelector) { (elem, idx, stop) -> Void in
            let enumName = elem.valueForAttribute("name") as! String
            let enumType = S3DMtlEnum(name: enumName, elem: elem)
            self.enumTypes[enumName] = enumType
        }
    }
    
    public func parseAttributeGroups() {
        let attributeGroupsSelector = "xs:attributeGroup"
        xml?.enumerateElementsWithCSS(attributeGroupsSelector) { (elem, idx, stop) -> Void in
            let groupName = elem.valueForAttribute("name") as! String
            let attrGroup = S3DAttributeGroup(name: groupName, elem: elem)
            self.attributeGroups[groupName] = attrGroup
        }
    }
    
    public func parseDescriptorTypes() {
        
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

public class S3DMtlDescriptor {
    
}
