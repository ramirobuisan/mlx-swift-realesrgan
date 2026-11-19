# mlx-swift-realesrgan

ESRGAN / Real-ESRGAN ×4 upscaling in Swift with [MLX](https://github.com/ml-explore/mlx-swift), for Apple silicon.
It loads the usual `.pth` files directly, with a loader that never runs pickle code.

```swift
import MLX
import RealESRGAN

let model = try RealESRGAN(url: URL(fileURLWithPath: "RealESRGAN_x4plus_anime_6B.pth"))
let big = model.upscale(rgb8)          // MLXArray [H, W, 3] uint8 -> [4H, 4W, 3] uint8
```

```bash
swift run -c release realesrgan RealESRGAN_x4plus_anime_6B.pth input.png output.png
```

(Command-line builds need the Metal shaders that mlx-swift compiles through Xcode: use `xcodebuild -scheme realesrgan`
or open the package in Xcode if `swift run` complains about the metallib.)

## Speed

RealESRGAN_x4plus_anime_6B, 1024×1344 → 4096×5376, Apple M5 Max:

| | time |
|---|---|
| **this package (MLX, fp16, 640 px tiles)** | **1.97 s** |
| stable-diffusion.cpp upscaler (ggml Metal) | 27.5 s |

The output matches stable-diffusion.cpp's to 60.6 dB PSNR.

## Models

The BasicSR **RRDBNet ×4** architecture (keys `conv_first`, `body.N.rdbK.convM`, `conv_up1`, `conv_up2`,
`conv_hr`, `conv_last`, optionally under `params_ema`/`params`), any number of blocks:
RealESRGAN_x4plus, RealESRGAN_x4plus_anime_6B and other ESRGAN-style ×4 models saved by BasicSR.
Old-style ESRGAN key names (`model.0`, `model.1.sub...`), ×2 models (pixel unshuffle) and other
architectures (SwinIR, DAT, ...) are reported as unsupported.

Big images are processed in tiles (640 px plus 24 px of context on each side, `tile:`/`pad:` to change)
so memory stays bounded.

## Safe `.pth` loading

`TorchCheckpoint.load(url:)` reads PyTorch's zip checkpoints (`torch.save`) and returns the tensors
as `[String: MLXArray]`. It implements the pickle opcodes a state dict uses and allows exactly three
callables: `collections.OrderedDict`, `torch._utils._rebuild_tensor_v2` and
`torch._utils._rebuild_parameter`. Float32, float16 and bfloat16 storages are supported. Anything else in the
file (other classes or functions, which is how malicious pickles execute code) makes it throw instead.
A checkpoint whose pickle calls `os.system` fails with `refusing to call posix.system from a checkpoint`,
and the command never runs.

## License

MIT
