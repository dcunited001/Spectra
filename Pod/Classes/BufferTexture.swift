//
//  BufferTexture.swift
//  Pods
//
//  Created by David Conner on 10/3/15.
//
//

import Metal
import simd

public class BufferTexture {
    public typealias ColorType = float4
    public var size: CGSize
    public var pixelSize = sizeof(ColorType)
    public var texture:MTLTexture
    
    // no pointer needed for this, just texture.replaceRegion() to write
    //private var pixelsPtr: UnsafeMutablePointer<Void> = nil
    
    init(device: MTLDevice, textureDescriptor: MTLTextureDescriptor) {
        size = CGSize(width: textureDescriptor.width, height: textureDescriptor.height)
        texture = device.newTextureWithDescriptor(textureDescriptor)
    }
    
    convenience init(device: MTLDevice, size: CGSize, format: MTLPixelFormat = MTLPixelFormat.RGBA32Float, mipmapped: Bool = false) {
        let texDesc = MTLTextureDescriptor.texture2DDescriptorWithPixelFormat(format, width: Int(size.width), height: Int(size.height), mipmapped: false)
        
        self.init(device: device, textureDescriptor: texDesc)
    }
    
    public func writePixels(pixels: [ColorType]) {
        let region = MTLRegionMake2D(0, 0, Int(size.width), Int(size.height))
        texture.replaceRegion(region, mipmapLevel: 0, withBytes: pixels, bytesPerRow: calcBytesPerRow())
    }
    
    public func calcBytesPerRow() -> Int {
        return Int(size.width) * pixelSize
    }
    
    public func calcTotalBytes() -> Int {
        return calcTotalBytes(Int(size.width), h: Int(size.height))
    }
    
    public func calcTotalBytes(w: Int, h: Int) -> Int {
        return w * h * pixelSize
    }
    
    public func randomPixels() -> [ColorType] {
        return (0...calcTotalBytes())
            .lazy
            .map { _ in self.randomPixel() }
    }
    
    public func randomPixel() -> float4 {
        return float4(Float(arc4random())/Float(UInt32.max), Float(arc4random())/Float(UInt32.max), Float(arc4random())/Float(UInt32.max), 1.0)
    }
}
