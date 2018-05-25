// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Submissions",
    dependencies: [
        .package(url: "https://github.com/vapor/leaf.git", from: "3.0.0-rc"),
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0")
    ],
    targets: [
        .target(name: "Submissions", dependencies: ["Leaf", "Vapor"]),
        .testTarget(name: "SubmissionsTests", dependencies: ["Submissions"])
    ]
)

