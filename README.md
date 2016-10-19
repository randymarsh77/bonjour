# Bonjour
Convenience task-based API around `NetServices`.

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
