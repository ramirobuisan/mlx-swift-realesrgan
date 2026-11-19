// realesrgan <model.pth|model.safetensors> <input image> <output.png> [--tile 640]
import Foundation
import MLX
import RealESRGAN

var args = Array(CommandLine.arguments.dropFirst())
var tile = 640
if let i = args.firstIndex(of: "--tile"), i + 1 < args.count, let t = Int(args[i + 1]) {
    tile = t
    args.removeSubrange(i ... i + 1)
}
guard args.count == 3 else {
    print("usage: realesrgan <model.pth|model.safetensors> <input image> <output.png> [--tile 640]")
    exit(2)
}
do {
    let t0 = Date()
    let model = try RealESRGAN(url: URL(fileURLWithPath: args[0]))
    guard let img = loadRGB(args[1]) else { throw NSError(domain: "realesrgan", code: 1, userInfo: [NSLocalizedDescriptionKey: "can't read \(args[1])"]) }
    let x = MLXArray(img.pixels, [img.height, img.width, 3])
    let t1 = Date()
    let y = model.upscale(x, tile: tile)
    let t2 = Date()
    try savePNG(y.asArray(UInt8.self), width: y.dim(1), height: y.dim(0), to: args[2])
    print(String(format: "%dx%d -> %dx%d (%d RRDB blocks): load %.2fs, upscale %.2fs", img.width, img.height,
                 y.dim(1), y.dim(0), model.blocks, t1.timeIntervalSince(t0), t2.timeIntervalSince(t1)))
} catch {
    FileHandle.standardError.write(Data("error: \(error.localizedDescription)\n".utf8))
    exit(1)
}
