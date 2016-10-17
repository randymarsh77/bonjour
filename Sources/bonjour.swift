import Foundation
import Async
import IDisposable
import Promise
import Scope

public enum ServiceProtocol
{
	case TCP
	case UDP
}

public enum ServiceType
{
	case Unregistered(identifier: String)
}

public enum Domain
{
	case AnyDomain
	case Local
	case Custom(String)
}

public struct BroadcastSettings
{
	public var name: String
	public var serviceType: ServiceType
	public var serviceProtocol: ServiceProtocol
	public var domain: Domain
	public var port: Int32

	public init(name: String, serviceType: ServiceType, serviceProtocol: ServiceProtocol, domain: Domain, port: Int32)
	{
		self.name = name
		self.serviceType = serviceType
		self.serviceProtocol = serviceProtocol
		self.domain = domain
		self.port = port
	}
}

public struct QuerySettings
{
	public var serviceType: ServiceType
	public var serviceProtocol: ServiceProtocol
	public var domain: Domain

	public init(serviceType: ServiceType, serviceProtocol: ServiceProtocol, domain: Domain)
	{
		self.serviceType = serviceType
		self.serviceProtocol = serviceProtocol
		self.domain = domain
	}
}

public class Bonjour {

	public static func Broadcast(_ settings: BroadcastSettings) -> Scope
	{
		let service = NetService(
			domain: StringFromDomain(settings.domain),
			type: BuildServiceString(settings.serviceType, settings.serviceProtocol),
			name: settings.name,
			port: settings.port)

		service.publish()

		return Scope {
			service.stop()
		}
	}

	public static func FindAll(_ settings: QuerySettings) -> Task<[NetService]>
	{
		return async { (task: Task<[NetService]>) -> [NetService] in
			let ps = Promise<NetServiceBrowser, [NetService]> { (browser) in
				await(FindAll(browser, settings))
			}
			let pa = ps.then { _ in
				Async.Wake(task)
			}

			DispatchQueue.main.async {
				let browser = NetServiceBrowser()
				DispatchQueue.global(qos: .default).async {
					pa.resolve(browser)
				}
			}

			Async.Suspend()
			return ps.value!
		}
	}

	private static func FindAll(_ browser: NetServiceBrowser, _ settings: QuerySettings) -> Task<[NetService]>
	{
		return async { (task: Task<[NetService]>) -> [NetService] in
			var result: [NetService] = []
			let delegate = BrowserDelegate { (services: [NetService]) in
				browser.stop()
				result = services
				Async.Wake(task)
			}

			browser.delegate = delegate
			browser.searchForServices(
				ofType: BuildServiceString(settings.serviceType, settings.serviceProtocol),
				inDomain: StringFromDomain(settings.domain))

			Async.Suspend()
			return result
		}
	}
}

internal func StringFromDomain(_ domain: Domain) -> String
{
	switch domain {
	case .AnyDomain:
		return ""
	case .Local:
		return "local"
	case .Custom(let v):
		return v
	}
}

internal func StringFromProtocol(_ proto: ServiceProtocol) -> String
{
	switch proto {
	case .TCP:
		return "_tcp"
	case .UDP:
		return "_udp"
	}
}

internal func StringFromType(_ type: ServiceType) -> String
{
	switch type {
	case .Unregistered(let v):
		return v
	}
}

internal func BuildServiceString(_ type: ServiceType, _ proto: ServiceProtocol)-> String
{
	return String(format: "%@.%@", StringFromType(type), StringFromProtocol(proto))
}

internal typealias OnSearchCompleted = (_ onSearchCompleted: [NetService]) -> ()

internal class BrowserDelegate : NSObject, NetServiceBrowserDelegate
{
	var onSearchCompleted: OnSearchCompleted
	var servicesFound: [NetService] = []

	public init(onSearchCompleted: @escaping OnSearchCompleted)
	{
		self.onSearchCompleted = onSearchCompleted
	}

	public func netServiceBrowserDidStopSearch(_ browser: NetServiceBrowser)
	{
		self.onSearchCompleted(self.servicesFound)
	}

	public func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool)
	{
		self.servicesFound.append(service)
	}
}
