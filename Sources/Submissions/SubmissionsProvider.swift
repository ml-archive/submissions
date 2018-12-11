import Leaf
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

public extension LeafTagConfig {
    public mutating func useSubmissionsLeafTags(on container: Container) throws {
        let config: SubmissionsConfig = try container.make()
        let paths = config.tagTemplatePaths

        use([
            "submissions:email": InputTag(templatePath: paths.emailField),
            "submissions:password": InputTag(templatePath: paths.passwordField),
            "submissions:text": InputTag(templatePath: paths.textField),
            "submissions:hidden": InputTag(templatePath: paths.hiddenField),
            "submissions:textarea": InputTag(templatePath: paths.textareaField),
            "submissions:checkbox": InputTag(templatePath: paths.checkboxField)
        ])
    }
}
