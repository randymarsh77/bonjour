import PackageDescription

let package = Package(
    name: "Bonjour",
    dependencies: [
		.Package(url: "https://www.github.com/randymarsh77/async", majorVersion: 1),
		.Package(url: "https://www.github.com/randymarsh77/scope", majorVersion: 1),
	]
)
