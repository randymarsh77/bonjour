import XCTest
import Async
@testable import Bonjour

class BonjourTests: XCTestCase
{
	var settings = BroadcastSettings(
		name: "TestServiceName",
		serviceType: .Unregistered(identifier: "_testService"),
		serviceProtocol: .TCP,
		domain: .AnyDomain,
		port: 1234
	)

    func testBuildServiceString()
	{
		XCTAssertEqual(BuildServiceString(settings.serviceType, settings.serviceProtocol), "_testService._tcp")
    }

	func testFind()
	{
		let broadcastScope = Bonjour.Broadcast(settings)
		let services = await(Bonjour.FindAll(QuerySettings(serviceType: settings.serviceType, serviceProtocol: settings.serviceProtocol, domain: settings.domain)))
		broadcastScope.dispose()
		XCTAssertEqual(services.count, 1)
	}

    static var allTests : [(String, (BonjourTests) -> () throws -> Void)]
	{
        return [
            ("testBuildServiceString", testBuildServiceString),
        ]
    }
}
