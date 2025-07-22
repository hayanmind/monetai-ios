// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MonetaiSDK",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "MonetaiSDK",
            targets: ["MonetaiSDK"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.8.0"),
        .package(url: "https://github.com/realm/SwiftLint", from: "0.54.0")
    ],
    targets: [
        .target(
            name: "MonetaiSDK",
            dependencies: ["Alamofire"],
            path: "Sources/MonetaiSDK")
    ]
) 