import TemplateKit
import Sugar

/// A tag that renders a template file corresponding to a validatable form input element.
public final class InputTag: TagRenderer {
    struct InputData: Encodable {
        let key: String
        let value: String?
        let label: String?
        let isRequired: Bool
        let errors: [String]
        let hasErrors: Bool
        let placeholder: String?
        let helpText: String?
    }

    /// Create a new `InputTag`.
    ///
    /// - Parameter templatePath: path to the template file to render
    public init(templatePath: String) {
        render = { tagContext, inputData in
            try tagContext.requireNoBody()
            return try tagContext
                .container
                .make(TemplateRenderer.self)
                .render(templatePath, inputData)
                .map { .data($0.data) }
        }
    }

    let render: (TagContext, InputData) throws -> Future<TemplateData>

    /// See `TagRenderer`.
    public func render(tag: TagContext) throws -> Future<TemplateData> {
        let data = try tag.submissionsData()

        let placeholder = tag.parameters[safe: 1]?.string
        let helpText = tag.parameters[safe: 2]?.string

        return (data.errors ?? tag.future([])).flatMap {
            let inputData = InputData(
                key: data.key,
                value: data.value,
                label: data.label,
                isRequired: data.isRequired,
                errors: $0,
                hasErrors: !$0.isEmpty,
                placeholder: placeholder,
                helpText: helpText
            )
            return try self.render(tag, inputData)
        }
    }
}
