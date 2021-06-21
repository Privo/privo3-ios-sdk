// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PrivoSDK",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6)
    ], products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "PrivoSDK",
            targets: ["PrivoSDK"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.2.0")),
        .package(name: "JWTDecode", url: "https://github.com/auth0/JWTDecode.swift.git", .upToNextMajor(from: "2.6.1"))
        // .package(name: "AnyCodable", url: "https://github.com/Flight-School/AnyCodable", .upToNextMinor(from: "0.6.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "PrivoSDK",
            dependencies: ["Alamofire", "JWTDecode"]),
        .testTarget(
            name: "PrivoSDKTests",
            dependencies: ["PrivoSDK", "Alamofire", "JWTDecode"]),
    ]
)
