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
    
    public class func readXSD(filename: String) -> NSData {
        let podBundle = NSBundle(forClass: S3DXSD.self)
        let bundleUrl = podBundle.URLForResource("Spectra", withExtension: "bundle")
        let bundle = NSBundle(URL: bundleUrl!)
        let path = bundle!.pathForResource("Spectra3D", ofType: "xsd")
        let data = NSData(contentsOfFile: path!)
        return data!
    }
    
    public func parseEnumTypes() {
        let enumTypesSelector = "xs:simpleType[mtl-enum=true]"
        xml!.enumerateElementsWithCSS(enumTypesSelector) { (elem, idx, stop) -> Void in
            let enumType = S3DMtlEnum(elem: elem)
            self.enumTypes[enumType.name] = enumType
        }
    }
    
    public func parseAttributeGroups() {
        let attributeGroupsSelector = "xs:attributeGroup[name]"
        xml!.enumerateElementsWithCSS(attributeGroupsSelector) { (elem, idx, stop) -> Void in
            let attrGroup = S3DAttributeGroup(elem: elem)
            self.attributeGroups[attrGroup.name] = attrGroup
        }
    }
    
    public func parseDescriptorTypes() {
        // TODO: force XSD to process in stages by using multiple complexTypesSelector's
        let complexTypesSelector = "xs:complexType"
        xml!.enumerateElementsWithCSS(complexTypesSelector) { (elem, idx, stop) -> Void in
            let descriptorType = S3DMtlDescriptorType(elem: elem)
            self.descriptorTypes[descriptorType.name] = descriptorType
        }
    }
}

public class S3DAttributeGroup {
    public var name: String
    public var attributes: [String: String] = [:] // name, type ... needs more?
    
    public init(elem: ONOXMLElement) {
        self.name = elem.valueForAttribute("name") as! String
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
    
    public init(elem: ONOXMLElement) {
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

public class S3DMtlDescriptorElement {
    public var name: String
    public var descriptorTypeMap: [String: String] = [:]
    
    public init(name:String) {
        self.name = name
    }
}

public class S3DMtlDescriptorType {
    public var name: String
    
    public init(elem: ONOXMLElement) {
        self.name = elem.valueForAttribute("name") as! String
        
    }
}
