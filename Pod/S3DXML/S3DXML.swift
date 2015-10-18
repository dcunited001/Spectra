//
//  S3DXML.swift
//  Pods
//
//  Created by David Conner on 10/12/15.
//
//

import Foundation
import Metal
import Ono

public class SpectraDescriptorManager {
    public var library: MTLLibrary // TODO: support multiple libraries?
    //TODO: load mtlEnums
    
    public var xsd: S3DXSD
    public var mtlEnums: [String: S3DMtlEnum] = [:]
    public var vertexFunctions: [String: MTLFunction] = [:]
    public var fragmentFunctions: [String: MTLFunction] = [:]
    public var computeFunctions: [String: MTLFunction] = [:]
    
    public var vertexDescriptors: [String: MTLVertexDescriptor] = [:]
    public var textureDescriptors: [String: MTLTextureDescriptor] = [:]
    public var samplerDescriptors: [String: MTLSamplerDescriptor] = [:]
    public var stencilDescriptors: [String: MTLStencilDescriptor] = [:]
    public var depthStencilDescriptors: [String: MTLStencilDescriptor] = [:]
    public var colorAttachmentDescriptors: [String: MTLRenderPipelineColorAttachmentDescriptor] = [:]
    public var renderPipelineDescriptors: [String: MTLRenderPipelineDescriptor] = [:]
    public var renderPassColorAttachmentDescriptors: [String: MTLRenderPassColorAttachmentDescriptor] = [:]
    public var renderPassDepthAttachmentDescriptors: [String: MTLRenderPassDepthAttachmentDescriptor] = [:]
    public var renderPassStencilAttachmentDescriptors: [String: MTLRenderPassStencilAttachmentDescriptor] = [:]
    public var computePipelineDescriptors: [String: MTLComputePipelineDescriptor] = [:]
    
    public init(library: MTLLibrary) {
        self.library = library
        
        // just parsing enum types from XSD for now
        let xmlData = S3DXSD.readXSD("Spectra3D")
        xsd = S3DXSD(data: xmlData)
        xsd.parseEnumTypes()
    }
    
}

public class S3DXML {
    public var xml: ONOXMLDocument?
    
    public init(data: NSData) {
        xml = try! ONOXMLDocument(data: data)
    }
    
    public func parse(descriptorManager: SpectraDescriptorManager) -> SpectraDescriptorManager {
        for child in xml!.rootElement.children {
            let elem = child as! ONOXMLElement
            let tag = elem.tag
            let key = elem.valueForAttribute("key") as? String
            
            switch tag {
            case "vertex-function":
                descriptorManager.vertexFunctions[key!] = descriptorManager.vertexFunctions[key!] ?? S3DXMLMTLFunctionNode().parse(descriptorManager, elem: elem)
            case "vertex-descriptor":
                descriptorManager.vertexDescriptors[key!] = descriptorManager.vertexDescriptors[key!] ?? S3DXMLMTLVertexDescriptorNode().parse(descriptorManager, elem: elem)
//            case "texture-descriptor":
//            case "sampler-descriptor":
//            case "stencil-descriptor":
//            case "depth-stencil-descriptor":
//            case "color-attachment-descriptor":
            default:
                break
            }
        }
        
        return descriptorManager
    }
}

public protocol S3DXMLNodeParser {
    typealias NodeType
    
    func parse(descriptorManager: SpectraDescriptorManager, elem: ONOXMLElement, options: [String: AnyObject]) -> NodeType
}

//TODO: update valueForAttribute calls with guard statements and better error handling

public class S3DXMLMTLFunctionNode: S3DXMLNodeParser {
    public typealias NodeType = MTLFunction
    
    public func parse(descriptorManager: SpectraDescriptorManager, elem: ONOXMLElement, options: [String: AnyObject] = [:]) -> NodeType {
        let lib = descriptorManager.library
        let name = elem.valueForAttribute("key") as! String
        return lib.newFunctionWithName(name)!
    }
}

public class S3DXMLMTLVertexDescriptorNode: S3DXMLNodeParser {
    public typealias NodeType = MTLVertexDescriptor
    
    public func parse(descriptorManager: SpectraDescriptorManager, elem: ONOXMLElement, options: [String: AnyObject] = [:]) -> NodeType {
        
        // - build each VertexAttributeDescriptor & append
        // - build each BufferLayoutDescriptor & append
        return NodeType()
    }
    
    public func parseVertexAttributeDesciptor(elem: ONOXMLElement) -> MTLVertexAttributeDescriptor {
    }
    

    public func parseVertexBufferLayoutDescriptor(elem: ONOXMLElement) -> MTLVertexBufferLayoutDescriptor {
    }
}

public class S3DXMLMTLVertexAttributeDescriptorNode: S3DXMLNodeParser {
    public typealias NodeType = MTLVertexAttributeDescriptor
    
    public func parse(descriptorManager: SpectraDescriptorManager, elem: ONOXMLElement, options: [String : AnyObject]) -> NodeType {
        let vertexAttrDesc = NodeType()
        
        if let format = elem.valueForAttribute("format") as? String {
            //TODO: look up in mtlAttributeDescriptor
            vertexAttrDesc.format = MTLVertexFormat(rawValue: UInt(format)!)!
        }
        if let offset = elem.valueForAttribute("offset") as? String {
            vertexAttrDesc.offset = Int(offset)!
        }
        if let bufferIndex = elem.valueForAttribute("bufferIndex") as? String {
            vertexAttrDesc.bufferIndex = Int(bufferIndex)!
        }
        
        return vertexAttrDesc
    }
}

public class S3DXMLMTLVertexBufferLayoutDescriptorNode: S3DXMLNodeParser {
    public typealias NodeType = MTLVertexBufferLayoutDescriptor
    
    public func parse(descriptorManager: SpectraDescriptorManager, elem: ONOXMLElement, options: [String : AnyObject]) -> NodeType {

        let bufferLayoutDesc = NodeType()
        
        let stride = elem.valueForAttribute("stride") as! String
        bufferLayoutDesc.stride = Int(stride)!
        
        if let stepFunction = elem.valueForAttribute("step-function") as? String {
            bufferLayoutDesc.stepFunction = MTLVertexStepFunction(rawValue: UInt(stepFunction)!)!
        }
        if let stepRate = elem.valueForAttribute("step-rate") as? String {
            bufferLayoutDesc.stepRate = Int(stepRate)!
        }
        
        return bufferLayoutDesc
    }
}

//public class S3DXMLMTLTextureDescriptorNode: S3DXMLNodeParser {
//    public typealias NodeType = MTLTextureDescriptor
//    
//    public func parse(descriptorManager: SpectraDescriptorManager, elem: ONOXMLElement, options: [String : AnyObject]) -> NodeType {
//        
//        return NodeType()
//    }
//}

//public class S3DXMLMTLSamplerDescriptorNode: S3DXMLNodeParser {
//    public typealias NodeType =
//    public func parse(descriptorManager: SpectraDescriptorManager, elem: ONOXMLElement, options: [String : AnyObject]) -> NodeType {
//
//        return NodeType()
//    }
//}
//
//public class S3DXMLMTLStencilDescriptorNode: S3DXMLNodeParser {
//    public typealias NodeType =
//    public func parse(descriptorManager: SpectraDescriptorManager, elem: ONOXMLElement, options: [String : AnyObject]) -> NodeType {
//
//        return NodeType()
//    }//}
//
//public class S3DXMLMTLDepthStencilDescriptorNode: S3DXMLNodeParser {
//    public typealias NodeType =
//    public func parse(descriptorManager: SpectraDescriptorManager, elem: ONOXMLElement, options: [String : AnyObject]) -> NodeType {
//
//        return NodeType()
//    }
//}
//
//public class S3DXMLMTLColorAttachmentDescriptorNode: S3DXMLNodeParser {
//    public typealias NodeType =
//    public func parse(descriptorManager: SpectraDescriptorManager, elem: ONOXMLElement, options: [String : AnyObject]) -> NodeType {
//
//        return NodeType()
//    }
//}

//
//public class S3DXMLMTLVertexDescriptorNode: S3DXMLNodeParser {
//    public typealias NodeType =
//    public func parse(descriptorManager: SpectraDescriptorManager, elem: ONOXMLElement, options: [String : AnyObject]) -> NodeType {
//
//        return NodeType()
//    }
//}

