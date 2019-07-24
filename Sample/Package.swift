// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "swift-aws-sample",
    products: [
        .library(name: "Sample", targets: ["Sample"])
    ],
    dependencies: [
        .package(url: "https://github.com/swift-aws/aws-sdk-swift.git", .upToNextMinor(from: "3.1.0")),
        .package(url: "https://github.com/kperson/swift-lambda-tools.git", .branch("master"))
    ],
    targets: [
        .target(
            name: "Sample",
            dependencies: [
                "SwiftAWS",
                "SNS",
                "SQS",
                "S3",
                "DynamoDB"
            ],
            path: "./Sources"
        )
    ]
)
