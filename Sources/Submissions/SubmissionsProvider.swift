import Service
import Vapor

public final class SubmissionsProvider: Provider {
    public init() {}
    
    public func register(_ services: inout Services) throws {
        services.register { _ in FieldCache() }
    }

    public func didBoot(_ container: Container) throws -> Future<Void> {
        return .done(on: container)
    }
}

extension SubmissionsProvider {
    public static var tags: [String: TagRenderer] {
        return ["textgroup": TextGroupTag()]
    }
}
