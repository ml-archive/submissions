import Sugar
import Vapor

/// A provider that registers tags and a `FieldCache`.
public final class SubmissionsProvider: Provider {

    /// Submissions configuration
    public let config: SubmissionsConfig

    /// Create a new `SubmissionsProvider`.
    public init(config: SubmissionsConfig = .default) {
        self.config = config
    }

    /// See `Provider`
    public func register(_ services: inout Services) throws {
        try services.register(MutableLeafTagConfigProvider())
        services.register(config)
        services.register { _ in FieldCache() }
    }

    /// See `Provider`
    public func didBoot(_ container: Container) throws -> Future<Void> {
        let tags: MutableLeafTagConfig = try container.make()
        let paths = config.tagTemplatePaths
        tags.use([
            "submissions:email": InputTag(templatePath: paths.emailField),
            "submissions:password": InputTag(templatePath: paths.passwordField),
            "submissions:text": InputTag(templatePath: paths.textField),
            "submissions:hidden": InputTag(templatePath: paths.hiddenField),
            "submissions:textarea": InputTag(templatePath: paths.textareaField)
        ])

        return .done(on: container)
    }
}
