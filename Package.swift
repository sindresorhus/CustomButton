// swift-tools-version:5.7
import PackageDescription

let package = Package(
	name: "CustomButton",
	platforms: [
		.macOS(.v10_12)
	],
	products: [
		.library(
			name: "CustomButton",
			targets: [
				"CustomButton"
			]
		)
	],
	targets: [
		.target(
			name: "CustomButton"
		)
	]
)
