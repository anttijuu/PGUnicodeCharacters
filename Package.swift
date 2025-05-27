// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PGUnicodeCharacters",
	 platforms: [
		.macOS(.v10_15)
	 ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
		  .package(url: "https://github.com/apple/swift-system", from: "1.4.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "PGUnicodeCharacters",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
					 .product(name: "SystemPackage", package: "swift-system"),
            ]
        ),
    ]
)
