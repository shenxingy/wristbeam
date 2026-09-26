// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "WristScrollCore",
    platforms: [.iOS(.v17), .watchOS(.v10), .macOS(.v13)],
    products: [.library(name: "WristScrollCore", targets: ["WristScrollCore"])],
    targets: [
        .target(name: "WristScrollCore", path: "Shared"),
        .testTarget(name: "WristScrollCoreTests", dependencies: ["WristScrollCore"], path: "Tests/CoreTests")
    ]
)
