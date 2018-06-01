import Service
import Vapor

/// A provider that registers a FieldCache.
public final class SubmissionsProvider: Provider {
    public let config: SubmissionsConfig

    /// Create a new `SubmissionsProvider`.
    public init(config: SubmissionsConfig = .default) {
        self.config = config
    }
    
    /// See `Provider`
    public func register(_ services: inout Services) throws {
        services.register(config)
        services.register { _ in FieldCache() }
    }

    /// See `Provider`
    public func didBoot(_ container: Container) throws -> Future<Void> {
        return .done(on: container)
    }
}

extension SubmissionsProvider {

    /// The Submission related tags.
    public static var tags: [String: TagRenderer] {
        return ["submissions:input": InputTag()]
    }
}
