# Bonjour
Convenience task-based API around `NetServices`.

## Example

```
import Foundation
import Bonjour
import Async

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

var keepRunning = true
let broadcastScope = Bonjour.Broadcast(bSettings)
DispatchQueue.global(qos: .default).async {
	let services = await(Bonjour.FindAll(qSettings))
	DispatchQueue.main.async {
		print("Found %d services", services.count)
		broadcastScope.dispose()
		keepRunning = false
	}
}

while (keepRunning) { RunLoop.current.run(until: Date(timeIntervalSinceNow: 1)) }
```
