import Vapor

/// A provider that registers a `FieldCache`.
public final class SubmissionsProvider: Provider {

    /// Create a new `SubmissionsProvider`.
    public init() {}

    /// See `Provider`
    public func register(_ services: inout Services) throws {
        services.register { _ in FieldCache() }
    }

    /// See `Provider`
    public func didBoot(_ container: Container) throws -> Future<Void> {
        return .done(on: container)
    }
}
