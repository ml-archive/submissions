import Leaf
import Service
import Sugar
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
        let tags = try container.make(MutableLeafTagConfig.self)
        let paths = config.tagTemplatePaths
        tags.use([
            "submissions:input": InputTag(),
            "submissions:email": InputTag(templatePath: paths.emailField),
            "submissions:password": InputTag(templatePath: paths.passwordField),
            "submissions:text": InputTag(templatePath: paths.textField)
        ])

        return .done(on: container)
    }
}
