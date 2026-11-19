// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "mlx-swift-realesrgan",
    platforms: [.macOS(.v14), .iOS(.v17)],
    products: [
        .library(name: "RealESRGAN", targets: ["RealESRGAN"]),
        .executable(name: "realesrgan", targets: ["realesrgan-cli"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ml-explore/mlx-swift", .upToNextMinor(from: "0.31.4")),
    ],
    targets: [
        .target(
            name: "RealESRGAN",
            dependencies: [
                .product(name: "MLX", package: "mlx-swift"),
                .product(name: "MLXNN", package: "mlx-swift"),
            ]),
        .executableTarget(name: "realesrgan-cli", dependencies: ["RealESRGAN"]),
    ]
)
