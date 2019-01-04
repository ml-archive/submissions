// swift-tools-version:4.1
import PackageDescription

let package = Package(
    name: "Submissions",
    products: [
        .library(name: "Submissions", targets: ["Submissions"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/leaf.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/template-kit.git", from: "1.0.0"),
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),
        .package(url: "https://github.com/nodes-vapor/sugar.git", from: "3.0.0"),
    ],
    targets: [
        .target(name: "Submissions", dependencies: ["Leaf", "Sugar", "TemplateKit", "Vapor"]),
        .testTarget(name: "SubmissionsTests", dependencies: ["Submissions"])
    ]
)
