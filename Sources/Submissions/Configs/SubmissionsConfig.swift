import Service

public struct SubmissionsConfig: Service {
    public let viewPaths: SubmissionsViewPaths

    public init(
        viewPaths: SubmissionsViewPaths
    ) {
        self.viewPaths = viewPaths
    }

    public static var `default`: SubmissionsConfig {
        return .init(
            viewPaths: .init()
        )
    }
}
