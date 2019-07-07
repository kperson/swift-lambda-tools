// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "swift-aws",
    products: [
        .library(name: "SwiftAWS", targets: ["SwiftAWS"]),
        .library(name: "Sample", targets: ["Sample"])
    ],
    dependencies: [
        .package(url: "https://github.com/kperson/vapor-lambda-adapter.git", .branch("master")),
        .package(url: "https://github.com/swift-aws/aws-sdk-swift.git", .upToNextMinor(from: "3.0.0"))
    ],
    targets: [
        .target(
            name: "SwiftAWS", 
            dependencies: [
                "VaporLambdaAdapter"
            ],
            path: "./Sources"
        ),
        .target(
            name: "Sample",
            dependencies: [
                "SwiftAWS",
                "DynamoDB"
            ],
            path: "./Sample"
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
