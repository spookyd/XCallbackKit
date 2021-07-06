// swift-tools-version:5.4

import PackageDescription

let package = Package(
    name: "XCallbackKit",
    platforms: [.iOS(.v10)],
    products: [
      .library(name: "XCallbackKit", targets: ["XCallbackKit"])
    ],
    dependencies: [
    ],
    targets: [
      .target(
        name: "XCallbackKit",
        dependencies: [
        ],
        path: "XCallbackKit"
      ),
      .testTarget(
        name: "XCallbackKitTest",
        dependencies: [
            "XCallbackKit"
        ],
        path: "XCallbackKitTests"
      )
    ]
)
