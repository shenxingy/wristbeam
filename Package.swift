// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "WristbeamCore",
    platforms: [.iOS(.v17), .watchOS(.v10), .macOS(.v13)],
    products: [.library(name: "WristbeamCore", targets: ["WristbeamCore"])],
    targets: [
        .target(name: "WristbeamCore", path: "Shared"),
        .testTarget(name: "WristbeamCoreTests", dependencies: ["WristbeamCore"], path: "Tests/CoreTests")
    ]
)
