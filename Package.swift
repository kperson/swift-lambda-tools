// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "swift-aws",
    products: [
        .library(name: "SwiftAWS", targets: ["SwiftAWS"])
    ],
    dependencies: [
        .package(url: "https://github.com/kperson/vapor-lambda-adapter.git", .upToNextMinor(from: "1.0.0"))
    ],
    targets: [
        .target(
            name: "SwiftAWS", 
            dependencies: [
                "VaporLambdaAdapter"
            ],
            path: "./Sources"
        ),
        .testTarget(
            name: "SwiftAWSTests",
            dependencies: [
                "SwiftAWS"
            ],
            path: "./Tests"
        )
    ]
)
