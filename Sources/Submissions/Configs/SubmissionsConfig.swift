import Service

/// Configuration for Submissions
public struct SubmissionsConfig: Service {

    /// Configuration for template paths used when rendering tags.
    public let tagTemplatePaths: TagTemplatePaths

    /// Create a new config.
    ///
    /// - Parameter viewPaths: view path configuration.
    public init(
        tagTemplatePaths: TagTemplatePaths
    ) {
        self.tagTemplatePaths = tagTemplatePaths
    }

    /// Default configuration.
    public static var `default`: SubmissionsConfig {
        return .init(
            tagTemplatePaths: .init()
        )
    }
}
