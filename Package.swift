// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftPackageTest",
    platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "SwiftPackageTest",
            targets: ["SwiftPackageTest"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "SwiftPackageTest",
            dependencies: ["HealthKitFramework", "SportKitFramework"],  // 添加 SportKitFramework 作为依赖项
            path: "Sources",
            swiftSettings: [
                .define("HEALTHKIT_FRAMEWORK"),  // 定义宏名称而不传递路径
                .define("SPORTKIT_FRAMEWORK")    // 定义 SportKit 宏
            ]
        ),
        .binaryTarget(
            name: "HealthKitFramework",
            path: "./Frameworks/HealthKitFramework.xcframework"
        ),
        .binaryTarget(
            name: "SportKitFramework",  // 添加 SportKitFramework 的二进制目标
            path: "./Frameworks/SportKitFramework.xcframework"  // 这里是 SportKitFramework 的路径
        )
    ]
)


