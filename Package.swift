// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "zenea-swift-server",
    platforms: [
       .macOS("13.3")
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.92.1"),
        .package(url: "https://github.com/glasfisch3000/zenea-swift.git", from: "1.0.0-alpha3")
    ],
    targets: [
        .executableTarget(
            name: "zenea-swift-server",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "zenea", package: "zenea-swift"),
            ]
        )
    ]
)
