// swift-tools-version:5.9
import PackageDescription

let package = Package(
	name: "CustomButton",
	platforms: [
		.macOS(.v10_13)
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
