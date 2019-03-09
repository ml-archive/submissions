import TemplateKit

/// A tag that renders a template file corresponding to a file input element.
public final class FileTag: TagRenderer {
    struct InputData: Encodable {
        let key: String
        let value: String?
        let label: String?
        let isRequired: Bool
        let errors: [String]
        let hasErrors: Bool
        let helpText: String?
        let accept: String?
        let multiple: String?
    }

    /// Create a new `InputTag`.
    ///
    /// - Parameter templatePath: path to the template file to render
    public init(templatePath: String) {
        render = { tag, inputData in
            try tag.requireNoBody()
            return try tag
                .container
                .make(TemplateRenderer.self)
                .render(templatePath, inputData)
                .map { .data($0.data) }
        }
    }

    private let render: (TagContext, InputData) throws -> Future<TemplateData>

    /// See `TagRenderer`.
    public func render(tag: TagContext) throws -> Future<TemplateData> {
        let data = try tag.submissionsData()

        let helpText = tag.parameters[safe: 1]?.string
        let accept = tag.parameters[safe: 2]?.string
        let multiple = tag.parameters[safe: 3]?.string

        return (data.errors ?? tag.future([])).flatMap {
            let inputData = InputData(
                key: data.key,
                value: data.value,
                label: data.label,
                isRequired: data.isRequired,
                errors: $0,
                hasErrors: !$0.isEmpty,
                helpText: helpText,
                accept: accept,
                multiple: multiple
            )
            return try self.render(tag, inputData)
        }
    }
}
