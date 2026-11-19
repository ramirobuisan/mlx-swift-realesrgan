import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

/// RGB8 pixels of an image file (any format ImageIO reads).
func loadRGB(_ path: String) -> (pixels: [UInt8], width: Int, height: Int)? {
    guard let src = CGImageSourceCreateWithURL(URL(fileURLWithPath: path) as CFURL, nil),
          let cg = CGImageSourceCreateImageAtIndex(src, 0, nil) else { return nil }
    let (w, h) = (cg.width, cg.height)
    var rgba = [UInt8](repeating: 0, count: w * h * 4)
    rgba.withUnsafeMutableBytes { buf in
        let ctx = CGContext(data: buf.baseAddress, width: w, height: h, bitsPerComponent: 8, bytesPerRow: w * 4,
                            space: CGColorSpace(name: CGColorSpace.sRGB)!,
                            bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue)
        ctx?.draw(cg, in: CGRect(x: 0, y: 0, width: w, height: h))
    }
    var rgb = [UInt8](repeating: 0, count: w * h * 3)
    for i in 0 ..< w * h { rgb[i * 3] = rgba[i * 4]; rgb[i * 3 + 1] = rgba[i * 4 + 1]; rgb[i * 3 + 2] = rgba[i * 4 + 2] }
    return (rgb, w, h)
}

/// Write RGB8 pixels as PNG.
func savePNG(_ pixels: [UInt8], width: Int, height: Int, to path: String) throws {
    let data = CFDataCreate(nil, pixels, pixels.count)!
    guard let provider = CGDataProvider(data: data),
          let cg = CGImage(width: width, height: height, bitsPerComponent: 8, bitsPerPixel: 24, bytesPerRow: width * 3,
                           space: CGColorSpace(name: CGColorSpace.sRGB)!, bitmapInfo: CGBitmapInfo(rawValue: 0),
                           provider: provider, decode: nil, shouldInterpolate: false, intent: .defaultIntent),
          let dest = CGImageDestinationCreateWithURL(URL(fileURLWithPath: path) as CFURL, UTType.png.identifier as CFString, 1, nil)
    else { throw NSError(domain: "png", code: 1, userInfo: [NSLocalizedDescriptionKey: "could not write \(path)"]) }
    CGImageDestinationAddImage(dest, cg, nil)
    guard CGImageDestinationFinalize(dest) else { throw NSError(domain: "png", code: 2, userInfo: [NSLocalizedDescriptionKey: "could not write \(path)"]) }
}
