# Bonjour
Convenience task-based API around `NetServices`.

[![license](https://img.shields.io/github/license/mashape/apistatus.svg)]()
[![GitHub release](https://img.shields.io/github/release/randymarsh77/bonjour.svg)]()
[![SPM](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)
[![Build Status](https://api.travis-ci.org/randymarsh77/bonjour.svg?branch=master)](https://travis-ci.org/randymarsh77/bonjour)
[![codebeat badge](https://codebeat.co/badges/f9cf00a2-6fa6-4a3b-955e-5777b647b4c6)](https://codebeat.co/projects/github-com-randymarsh77-bonjour)

## Example

```
import Foundation
import Async
import Bonjour
import Using

let serviceType: ServiceType = .Unregistered(identifier: "_myService")

let bSettings = BroadcastSettings(
	name: "Bonjour World!",
	serviceType: serviceType,
	serviceProtocol: .TCP,
	domain: .AnyDomain,
	port: 1234
)

let qSettings = QuerySettings(
	serviceType: serviceType,
	serviceProtocol: .TCP,
	domain: .AnyDomain
)

using (Bonjour.Broadcast(bSettings)) {
	let services = await(Bonjour.FindAll(qSettings))
	print("Found \(services.count) service\(services.count == 1 ? "" : "s")")
}
```
