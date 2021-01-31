// swift-tools-version:5.1
import PackageDescription

let package = Package(
	name: "Bonjour",
	products: [
		.library(
			name: "Bonjour",
			targets: ["Bonjour"]
		),
	],
	dependencies: [
		.package(url: "https://github.com/randymarsh77/async", .branch("master")),
		.package(url: "https://github.com/randymarsh77/scope", .branch("master")),
	],
	targets: [
		.target(
			name: "Bonjour",
			dependencies: ["Async", "Scope"]
		),
		.testTarget(
			name: "BonjourTests",
			dependencies: ["Bonjour"]
		),
	]
)
