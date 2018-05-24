// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Submissions",
    dependencies: [
        .package(url: "https://github.com/nodes-vapor/sugar", .branch("vapor-3")),
        .package(url: "https://github.com/nodes-vapor/flash", from: "2.0.0-beta"),
        .package(url: "https://github.com/vapor/fluent-sqlite.git", from: "3.0.0-rc"),
        .package(url: "https://github.com/vapor/leaf.git", from: "3.0.0-rc"),
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0")
    ],
    targets: [
        .target(name: "App", dependencies: ["Flash", "FluentSQLite", "Submissions", "Sugar", "Vapor"]),
        .target(name: "Run", dependencies: ["App"]),
        .target(name: "Submissions", dependencies: ["Leaf", "Sugar", "Vapor"]),
        .testTarget(name: "SubmissionsTests", dependencies: ["Submissions"])
    ]
)

