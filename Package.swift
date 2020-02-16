// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "HelloWorld",
    products: [
        .library(name: "HelloWorld", targets: ["App"]),
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),
        .package(url: "https://github.com/idelfonsog2/app-models.git", .branch("master")),
		.package(url: "https://github.com/kylebrowning/APNSwift.git", .upToNextMinor(from: "1.3.0")),
        .package(url: "https://github.com/vapor/fluent-postgresql.git", from: "1.0.0")

    ],
    targets: [
        .target(name: "App", dependencies: ["FluentPostgreSQL", "Vapor", "AppModels", "APNSwift"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

