// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ur_registry_flutter",
    platforms: [.iOS("12.0")],
    products: [
        .library(name: "ur-registry-flutter", targets: ["ur_registry_flutter"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "ur_registry_flutter",
            dependencies: ["URRegistryFFI"]
        ),
        .binaryTarget(
            name: "URRegistryFFI",
            path: "ur_registry_ffi.xcframework"
        )
    ]
)
