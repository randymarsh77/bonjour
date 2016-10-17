import XCTest
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


    static var allTests : [(String, (BonjourTests) -> () throws -> Void)]
	{
        return [
            ("testBuildServiceString", testBuildServiceString),
        ]
    }
}
