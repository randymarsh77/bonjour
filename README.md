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

let broadcastScope = Bonjour.Broadcast(bSettings)
let services = await(Bonjour.FindAll(qSettings))
print("Found %d services", services.count)
broadcastScope.dispose()
```
