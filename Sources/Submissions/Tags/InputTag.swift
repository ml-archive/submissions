import TemplateKit

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
        let accept: String? // for file input
        let multiple: String? // for file input
    }
    
    let c: (TagContext, InputData) throws -> Future<TemplateData>

    public init(templatePath: String) {
        c = { tag, inputData in
            try tag.requireNoBody()
            return try tag
                .container
                .make(TemplateRenderer.self)
                .render(templatePath, inputData)
                .map { .data($0.data) }
        }
    }

    public func render(tag: TagContext) throws -> Future<TemplateData> {
        let data = try tag.submissionsData()

        let placeholder = tag.parameters[safe: 1]?.string
        let helpText = tag.parameters[safe: 2]?.string
        let accept = tag.parameters[safe: 3]?.string
        let multiple = tag.parameters[safe: 4]?.string

        let inputData = InputData(
            key: data.key,
            value: data.value,
            label: data.label,
            isRequired: data.isRequired,
            errors: data.errors,
            hasErrors: data.hasErrors,
            placeholder: placeholder,
            helpText: helpText,
            accept: accept,
            multiple: multiple
        )

        return try c(tag, inputData)
    }
}
