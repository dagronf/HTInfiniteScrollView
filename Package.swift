// swift-tools-version: 5.4

import PackageDescription

let package = Package(
	name: "HTInfiniteScrollView",
	platforms: [
		.macOS(.v10_13)
	],
	products: [
		.library(
			name: "HTInfiniteScrollView",
			targets: ["HTInfiniteScrollView"]),
	],
	targets: [
		.target(
			name: "HTInfiniteScrollView"),
		.testTarget(
			name: "HTInfiniteScrollViewTests",
			dependencies: ["HTInfiniteScrollView"]),
	]
)
