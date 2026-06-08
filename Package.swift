// swift-tools-version:6.3

import PackageDescription

let package = Package(
	name: "CoreSwiftVISA",
    platforms: [.macOS(.v26)],
	products: [
		.library(
			name: "CoreSwiftVISA",
			targets: ["CoreSwiftVISA"]),
	],
	targets: [
		.target(
			name: "CoreSwiftVISA",
      dependencies: []),
		.testTarget(
			name: "CoreSwiftVISATests",
			dependencies: ["CoreSwiftVISA"]),
	]
)
