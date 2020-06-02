// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "submissions ",
    platforms: [
         .macOS(.v10_15)
    ],
    products: [
        .library(name: "Submissions", targets: ["Submissions"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0")
    ],
    targets: [
        .target(name: "Submissions", dependencies: [.product(name: "Vapor", package: "vapor")]),
        .testTarget(name: "SubmissionsTests", dependencies: [
            .target(name:"Submissions"),
            .product(name: "XCTVapor", package: "vapor")
        ])
    ]
)
