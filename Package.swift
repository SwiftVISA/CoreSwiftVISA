// swift-tools-version:5.5

import PackageDescription

let package = Package(
	name: "CoreSwiftVISA",
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
