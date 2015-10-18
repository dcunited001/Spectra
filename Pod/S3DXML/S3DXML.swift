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
        mtlEnums = xsd.enumTypes
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
//                descriptorManager.textureDescriptors[key!] = descriptorManager.vertexDescriptors[key!] ?? S3DXMLMTLTextureDescriptorNode().parse(descriptorManager, elem: elem)
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
    
//    public func parseXML(bundle:NSBundle, filename: String) {
//        let xmlData = S3DXML.readXML(bundle, filename: "TestXML")
//        xml.parse(self)
    //    }
    
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
        let vertexDesc = NodeType()
        
        let attributeDescSelector = "vertex-attribute-descriptors > vertex-attribute-descriptor"
        elem.enumerateElementsWithCSS(attributeDescSelector) {(el, idx, stop) in
            let node = S3DXMLMTLVertexAttributeDescriptorNode()
            vertexDesc.attributes[Int(idx)] = node.parse(descriptorManager, elem: el)
        }
        
        let bufferLayoutDescSelector = "vertex-buffer-layout-descriptors > vertex-buffer-layout-descriptor"
        elem.enumerateElementsWithCSS(bufferLayoutDescSelector) { (el, idx, stop) in
            let node = S3DXMLMTLVertexBufferLayoutDescriptorNode()
            vertexDesc.layouts[Int(idx)] = node.parse(descriptorManager, elem: el)
        }
        
        return vertexDesc
    }
}

public class S3DXMLMTLVertexAttributeDescriptorNode: S3DXMLNodeParser {
    public typealias NodeType = MTLVertexAttributeDescriptor
    
    public func parse(descriptorManager: SpectraDescriptorManager, elem: ONOXMLElement, options: [String : AnyObject] = [:]) -> NodeType {
        let vertexAttrDesc = NodeType()
        
        if let format = elem.valueForAttribute("format") as? String {
            let mtlEnum = descriptorManager.mtlEnums["mtlVertexFormat"]!
            let enumVal = UInt(mtlEnum.getValue(format))
            vertexAttrDesc.format = MTLVertexFormat(rawValue: enumVal)!
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
    
    public func parse(descriptorManager: SpectraDescriptorManager, elem: ONOXMLElement, options: [String : AnyObject] = [:]) -> NodeType {

        let bufferLayoutDesc = NodeType()
        
        let stride = elem.valueForAttribute("stride") as! String
        bufferLayoutDesc.stride = Int(stride)!
        
        if let stepFunction = elem.valueForAttribute("step-function") as? String {
            let mtlEnum = descriptorManager.mtlEnums["mtlVertexStepFunction"]!
            let enumVal = UInt(mtlEnum.getValue(stepFunction))
            bufferLayoutDesc.stepFunction = MTLVertexStepFunction(rawValue: enumVal)!
        }
        if let stepRate = elem.valueForAttribute("step-rate") as? String {
            bufferLayoutDesc.stepRate = Int(stepRate)!
        }
        
        return bufferLayoutDesc
    }
}

public class S3DXMLMTLTextureDescriptorNode: S3DXMLNodeParser {
    public typealias NodeType = MTLTextureDescriptor
    
    public func parse(descriptorManager: SpectraDescriptorManager, elem: ONOXMLElement, options: [String : AnyObject] = [:]) -> NodeType {
        
        let texDesc = NodeType()
        if let textureType = elem.valueForAttribute("texture-type") as? String {
            let mtlEnum = descriptorManager.mtlEnums["mtlTextureType"]!
            let enumVal = UInt(mtlEnum.getValue(textureType))
            texDesc.textureType = MTLTextureType(rawValue: enumVal)!
        }
        if let pixelFormat = elem.valueForAttribute("pixel-format") as? String {
            let mtlEnum = descriptorManager.mtlEnums["mtlPixelFormat"]!
            let enumVal = UInt(mtlEnum.getValue(pixelFormat))
            texDesc.pixelFormat = MTLPixelFormat(rawValue: enumVal)!
        }
        if let width = elem.valueForAttribute("width") as? String {
            texDesc.width = Int(width)!
        }
        if let height = elem.valueForAttribute("height") as? String {
            texDesc.height = Int(height)!
        }
        if let depth = elem.valueForAttribute("depth") as? String {
            texDesc.depth = Int(depth)!
        }
        if let mipmapLevelCount = elem.valueForAttribute("mipmap-level-count") as? String {
            texDesc.mipmapLevelCount = Int(mipmapLevelCount)!
        }
        if let sampleCount = elem.valueForAttribute("sample-count") as? String {
            texDesc.sampleCount = Int(sampleCount)!
        }
        if let arrayLength = elem.valueForAttribute("array-length") as? String {
            texDesc.arrayLength = Int(arrayLength)!
        }
        //TODO: resourceOptions is option set type
        // texDesc.resourceOptions?  optional?  set later?
        if let cpuCacheMode = elem.valueForAttribute("cpu-cache-mode") as? String {
            let mtlEnum = descriptorManager.mtlEnums["mtlTextureType"]!
            let enumVal = UInt(mtlEnum.getValue(cpuCacheMode))
            texDesc.cpuCacheMode = MTLCPUCacheMode(rawValue: enumVal)!
        }
        if let storageMode = elem.valueForAttribute("storage-mode") as? String {
            let mtlEnum = descriptorManager.mtlEnums["mtlStorageMode"]!
            let enumVal = UInt(mtlEnum.getValue(storageMode))
            texDesc.storageMode = MTLStorageMode(rawValue: enumVal)!
        }
        if let usage = elem.valueForAttribute("usage") as? String {
            //TODO: option set type
            let mtlEnum = descriptorManager.mtlEnums["mtlTextureUsage"]!
            let enumVal = UInt(mtlEnum.getValue(usage))
            texDesc.usage = MTLTextureUsage(rawValue: enumVal)
        }
        
        return texDesc
    }
}

public class S3DXMLMTLSamplerDescriptorNode: S3DXMLNodeParser {
    public typealias NodeType = MTLSamplerDescriptor
    
    public func parse(descriptorManager: SpectraDescriptorManager, elem: ONOXMLElement, options: [String : AnyObject] = [:]) -> NodeType {
        let samplerDesc = NodeType()
        
        if let label = elem.valueForAttribute("label") as? String {
            samplerDesc.label = label
        }
        if let minFilter = elem.valueForAttribute("min-filter") as? String {
            let mtlEnum = descriptorManager.mtlEnums["mtlSamplerMinMapFilter"]!
            let enumVal = UInt(mtlEnum.getValue(minFilter))
            samplerDesc.minFilter = MTLSamplerMinMagFilter(rawValue: enumVal)!
        }
        if let magFilter = elem.valueForAttribute("mag-filter") as? String {
            let mtlEnum = descriptorManager.mtlEnums["mtlSamplerMinMapFilter"]!
            let enumVal = UInt(mtlEnum.getValue(magFilter))
            samplerDesc.magFilter = MTLSamplerMinMagFilter(rawValue: enumVal)!
        }
        if let mipFilter = elem.valueForAttribute("mip-filter") as? String {
            let mtlEnum = descriptorManager.mtlEnums["mtlSamplerMipFilter"]!
            let enumVal = UInt(mtlEnum.getValue(mipFilter))
            samplerDesc.mipFilter = MTLSamplerMipFilter(rawValue: enumVal)!
        }
        if let maxAnisotropy = elem.valueForAttribute("max-anisotropy") as? String {
            samplerDesc.maxAnisotropy = Int(maxAnisotropy)!
        }
        if let sAddress = elem.valueForAttribute("s-address-mode") as? String {
            let mtlEnum = descriptorManager.mtlEnums["mtlSamplerAddressMode"]!
            let enumVal = UInt(mtlEnum.getValue(sAddress))
            samplerDesc.sAddressMode = MTLSamplerAddressMode(rawValue: enumVal)!
        }
        if let rAddress = elem.valueForAttribute("r-address-mode") as? String {
            let mtlEnum = descriptorManager.mtlEnums["mtlSamplerAddressMode"]!
            let enumVal = UInt(mtlEnum.getValue(rAddress))
            samplerDesc.rAddressMode = MTLSamplerAddressMode(rawValue: enumVal)!
        }
        if let tAddress = elem.valueForAttribute("t-address-mode") as? String {
            let mtlEnum = descriptorManager.mtlEnums["mtlSamplerAddressMode"]!
            let enumVal = UInt(mtlEnum.getValue(tAddress))
            samplerDesc.tAddressMode = MTLSamplerAddressMode(rawValue: enumVal)!
        }
        if let _ = elem.valueForAttribute("normalized-coordinates") as? String {
            samplerDesc.normalizedCoordinates = true
        }
        if let lodMinClamp = elem.valueForAttribute("lod-min-clamp") as? String {
            samplerDesc.lodMinClamp = Float(lodMinClamp)!
        }
        if let lodMaxClamp = elem.valueForAttribute("lod-max-clamp") as? String {
            samplerDesc.lodMaxClamp = Float(lodMaxClamp)!
        }
        if let _ = elem.valueForAttribute("lod-average") as? String {
            samplerDesc.lodAverage = true
        }
        if let compareFn = elem.valueForAttribute("compare-function") as? String {
            let mtlEnum = descriptorManager.mtlEnums["mtlCompareFunction"]!
            let enumVal = UInt(mtlEnum.getValue(compareFn))
            samplerDesc.compareFunction = MTLCompareFunction(rawValue: enumVal)!
        }
        
        return samplerDesc
    }
}

public class S3DXMLMTLStencilDescriptorNode: S3DXMLNodeParser {
    public typealias NodeType = MTLStencilDescriptor
    
    public func parse(descriptorManager: SpectraDescriptorManager, elem: ONOXMLElement, options: [String : AnyObject] = [:]) -> NodeType {
        let stencilDesc = NodeType()
        
        if let stencilCompare = elem.valueForAttribute("stencil-compare-function") as? String {
            let mtlEnum = descriptorManager.mtlEnums["mtlCompareOperation"]!
            let enumVal = UInt(mtlEnum.getValue(stencilCompare))
            stencilDesc.stencilCompareFunction = MTLCompareFunction(rawValue: enumVal)!
        }
        if let stencilFailureOp = elem.valueForAttribute("stencil-failure-oparation") as? String {
            let mtlEnum = descriptorManager.mtlEnums["mtlStencilOperation"]!
            let enumVal = UInt(mtlEnum.getValue(stencilFailureOp))
            stencilDesc.stencilFailureOperation = MTLStencilOperation(rawValue: enumVal)!
        }
        if let depthFailureOp = elem.valueForAttribute("depth-failure-operation") as? String {
            let mtlEnum = descriptorManager.mtlEnums["mtlStencilOperation"]!
            let enumVal = UInt(mtlEnum.getValue(depthFailureOp))
            stencilDesc.depthFailureOperation = MTLStencilOperation(rawValue: enumVal)!
        }
        if let depthStencilPassOp = elem.valueForAttribute("depth-stencil-pass-operation") as? String {
            let mtlEnum = descriptorManager.mtlEnums["mtlStencilOperation"]!
            let enumVal = UInt(mtlEnum.getValue(depthStencilPassOp))
            stencilDesc.depthStencilPassOperation = MTLStencilOperation(rawValue: enumVal)!
        }
        if let readMask = elem.valueForAttribute("read-mask") as? String {
            stencilDesc.readMask = UInt32(readMask)!
        }
        if let writeMask = elem.valueForAttribute("write-mask") as? String {
            stencilDesc.writeMask = UInt32(writeMask)!
        }
        
        return stencilDesc
    }
}

public class S3DXMLMTLDepthStencilDescriptorNode: S3DXMLNodeParser {
    public typealias NodeType = MTLDepthStencilDescriptor
    
    public func parse(descriptorManager: SpectraDescriptorManager, elem: ONOXMLElement, options: [String : AnyObject] = [:]) -> NodeType {
        let depthDesc = NodeType()
        
        if let label = elem.valueForAttribute("label") as? String {
            depthDesc.label = label
        }
        if let depthCompare = elem.valueForAttribute("depth-compare-function") as? String {
            let mtlEnum = descriptorManager.mtlEnums["mtlCompareOperation"]!
            let enumVal = UInt(mtlEnum.getValue(depthCompare))
            depthDesc.depthCompareFunction = MTLCompareFunction(rawValue: enumVal)!
        }
        if let _ = elem.valueForAttribute("depth-write-enabled") as? String {
            depthDesc.depthWriteEnabled = true
        }
        
        return depthDesc
    }
}

public class S3DXMLMTLColorAttachmentDescriptorNode: S3DXMLNodeParser {
    public typealias NodeType = MTLRenderPipelineColorAttachmentDescriptor
    
    public func parse(descriptorManager: SpectraDescriptorManager, elem: ONOXMLElement, options: [String : AnyObject] = [:]) -> NodeType {
        let desc = NodeType()
        
        if let pixelFormat = elem.valueForAttribute("pixel-format") as? String {
            let mtlEnum = descriptorManager.mtlEnums["mtlPixelFormat"]!
            let enumVal = UInt(mtlEnum.getValue(pixelFormat))
            desc.pixelFormat = MTLPixelFormat(rawValue: enumVal)!
        }
        if let _ = elem.valueForAttribute("blending-enabled") as? String {
            desc.blendingEnabled = true
        }
        if let sourceRgbBlendFactor = elem.valueForAttribute("-blend-factor") as? String {
            let mtlEnum = descriptorManager.mtlEnums["mtlBlendFactor"]!
            let enumVal = UInt(mtlEnum.getValue(sourceRgbBlendFactor))
            desc.sourceRGBBlendFactor = MTLBlendFactor(rawValue: enumVal)!
        }
        if let destRgbBlendFactor = elem.valueForAttribute("-blend-factor") as? String {
            let mtlEnum = descriptorManager.mtlEnums["mtlBlendFactor"]!
            let enumVal = UInt(mtlEnum.getValue(destRgbBlendFactor))
            desc.destinationRGBBlendFactor = MTLBlendFactor(rawValue: enumVal)!
        }
        if let rgbBlendOp = elem.valueForAttribute("-blend-operation") as? String {
            let mtlEnum = descriptorManager.mtlEnums["mtlBlendOperation"]!
            let enumVal = UInt(mtlEnum.getValue(rgbBlendOp))
            desc.rgbBlendOperation = MTLBlendOperation(rawValue: enumVal)!
        }
        if let sourceAlphaBlendFactor = elem.valueForAttribute("-blend-factor") as? String {
            let mtlEnum = descriptorManager.mtlEnums["mtlBlendFactor"]!
            let enumVal = UInt(mtlEnum.getValue(sourceAlphaBlendFactor))
            desc.sourceAlphaBlendFactor = MTLBlendFactor(rawValue: enumVal)!
        }
        if let destAlphaBlendFactor = elem.valueForAttribute("-blend-factor") as? String {
            let mtlEnum = descriptorManager.mtlEnums["mtlBlendFactor"]!
            let enumVal = UInt(mtlEnum.getValue(destAlphaBlendFactor))
            desc.destinationRGBBlendFactor = MTLBlendFactor(rawValue: enumVal)!
        }
        if let alphaBlendOp = elem.valueForAttribute("-blend-operation") as? String {
            let mtlEnum = descriptorManager.mtlEnums["mtlBlendOperation"]!
            let enumVal = UInt(mtlEnum.getValue(alphaBlendOp))
            desc.alphaBlendOperation = MTLBlendOperation(rawValue: enumVal)!
        }
        //TODO: writeMask
        
        return desc
    }
}


public class S3DXMLMTLRenderPipelineDescriptorNode: S3DXMLNodeParser {
    public typealias NodeType = MTLRenderPipelineDescriptor
    public func parse(descriptorManager: SpectraDescriptorManager, elem: ONOXMLElement, options: [String : AnyObject] = [:]) -> NodeType {
        let desc = NodeType()
        
        //TODO: vertex function
        //TODO: fragment function
        //TODO: vertex-descriptor
        //TODO: color attachments array
        
        if let label = elem.valueForAttribute("label") as? String {
            desc.label = label
        }
        if let _ = elem.valueForAttribute("alpha-to-coverage-enabled") as? String {
            desc.alphaToCoverageEnabled = true
        }
        if let _ = elem.valueForAttribute("alpha-to-one-enabled") as? String {
            desc.alphaToOneEnabled = true
        }
        if let _ = elem.valueForAttribute("rasterization-enabled") as? String {
            desc.rasterizationEnabled = true
        }
        if let depthPixelFormat = elem.valueForAttribute("depth-attachment-pixel-format") as? String {
            let mtlEnum = descriptorManager.mtlEnums["mtlPixelFormat"]!
            let enumVal = UInt(mtlEnum.getValue(depthPixelFormat))
            desc.depthAttachmentPixelFormat = MTLPixelFormat(rawValue: enumVal)!
        }
        if let stencilPixelFormat = elem.valueForAttribute("stencil-attachment-pixel-format") as? String {
            let mtlEnum = descriptorManager.mtlEnums["mtlPixelFormat"]!
            let enumVal = UInt(mtlEnum.getValue(stencilPixelFormat))
            desc.stencilAttachmentPixelFormat = MTLPixelFormat(rawValue: enumVal)!
        }
        
        return desc
    }
}

public class S3DXMLMTLComputePipelineDescriptorNode: S3DXMLNodeParser {
    public typealias NodeType = MTLComputePipelineDescriptor
    public func parse(descriptorManager: SpectraDescriptorManager, elem: ONOXMLElement, options: [String : AnyObject] = [:]) -> NodeType {
        let desc = NodeType()
        
        //TODO: compute function
        
        if let label = elem.valueForAttribute("label") as? String {
            desc.label = label
        }
        if let threadGroupSizeIsMultiple = elem.valueForAttribute("thread-group-size-is-multiple-of-thread-execution-width") {
            desc.threadGroupSizeIsMultipleOfThreadExecutionWidth = true
        }
        
        return desc
    }
}



//
//public class S3DXMLMTLVertexDescriptorNode: S3DXMLNodeParser {
//    public typealias NodeType =
//    public func parse(descriptorManager: SpectraDescriptorManager, elem: ONOXMLElement, options: [String : AnyObject] = [:]) -> NodeType {
//let desc = NodeType()
//
//return desc
//    }
//}

