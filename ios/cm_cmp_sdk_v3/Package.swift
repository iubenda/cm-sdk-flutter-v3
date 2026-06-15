// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "cm_cmp_sdk_v3",
    platforms: [.iOS("13.0")],
    products: [
        .library(name: "cm-cmp-sdk-v3", targets: ["cm_cmp_sdk_v3"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/iubenda/cm-sdk-xcframework-v3.git",
            exact: "3.10.0"
        )
    ],
    targets: [
        .target(
            name: "cm_cmp_sdk_v3",
            dependencies: [
                .product(name: "cm-sdk-ios-v3", package: "cm-sdk-xcframework-v3")
            ]
        )
    ]
)
