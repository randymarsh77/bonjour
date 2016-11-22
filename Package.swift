import PackageDescription

let package = Package(
    name: "Bonjour",
    dependencies: [
		.Package(url: "https://github.com/randymarsh77/async", majorVersion: 1),
		.Package(url: "https://github.com/randymarsh77/scope", majorVersion: 1),
	]
)
