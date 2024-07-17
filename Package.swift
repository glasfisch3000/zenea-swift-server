// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "zenea-swift-server",
    platforms: [
       .macOS("13.3")
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.92.1"),
        .package(url: "https://github.com/zenea-project/zenea-swift.git", from: "3.1.0"),
        .package(url: "https://github.com/zenea-project/zenea-swift-files.git", from: "1.2.0"),
        .package(url: "https://github.com/zenea-project/zenea-swift-http.git", from: "1.1.0"),
    ],
    targets: [
        .executableTarget(
            name: "ZeneaSwiftServer",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "zenea-swift", package: "zenea-swift"),
                .product(name: "zenea-files", package: "zenea-swift-files"),
                .product(name: "zenea-http", package: "zenea-swift-http"),
            ],
            path: "./Sources/server/"
        )
    ]
)
