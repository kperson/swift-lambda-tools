// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "swift-aws",
    products: [
        .library(name: "SwiftAWS", targets: ["SwiftAWS"])
    ],
    dependencies: [
        .package(url: "https://github.com/kperson/vapor-lambda-adapter.git", .branch("master"))
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
                "SwiftAWS"
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
