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
	public var Name: String
	public var ServiceType: ServiceType
	public var ServiceProtocol: ServiceProtocol
	public var Domain: Domain
	public var Port: Int32
}

public struct QuerySettings
{
	public var ServiceType: ServiceType
	public var ServiceProtocol: ServiceProtocol
	public var Domain: Domain
}

public class Bonjour {

	public static func Broadcast(_ settings: BroadcastSettings) -> Scope
	{
		let service = NetService(
			domain: StringFromDomain(settings.Domain),
			type: BuildServiceString(settings.ServiceType, settings.ServiceProtocol),
			name: settings.Name,
			port: settings.Port)

		service.publish()

		return Scope {
			service.stop()
		}
	}

	public static func FindAll(_ settings: QuerySettings) -> Task<[NetService]>
	{
		return async { (task: Task<[NetService]>) -> [NetService] in
			let ps = Promise<NetServiceBrowser, [NetService]> { (browser) in
				await(task: FindAll(browser, settings))
			}
			let pa = ps.then { _ in
				Async.Wake(task: task)
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
				Async.Wake(task: task)
			}

			browser.delegate = delegate
			browser.searchForServices(
				ofType: BuildServiceString(settings.ServiceType, settings.ServiceProtocol),
				inDomain: StringFromDomain(settings.Domain))

			Async.Suspend()
			return result
		}
	}
}

private func StringFromDomain(_ domain: Domain) -> String
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

private func StringFromProtocol(_ proto: ServiceProtocol) -> String
{
	switch proto {
	case .TCP:
		return "_tcp"
	case .UDP:
		return "_udp"
	}
}

private func StringFromType(_ type: ServiceType) -> String
{
	switch type {
	case .Unregistered(let v):
		return v
	}
}

private func BuildServiceString(_ type: ServiceType, _ proto: ServiceProtocol)-> String
{
	return String(format: "%s.%s", StringFromType(type), StringFromProtocol(proto))
}

private typealias OnSearchCompleted = (_ onSearchCompleted: [NetService]) -> ()

private class BrowserDelegate : NSObject, NetServiceBrowserDelegate
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
