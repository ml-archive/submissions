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

    public init() {
        c = { tag, inputData in
            let body = try tag.requireBody()

            return tag.serializer.serialize(ast: body)
                .flatMap { view in
                    try tag
                        .container
                        .make(TemplateRenderer.self)
                        .render(template: view.data, inputData)
                }
                .map { .data($0.data) }
        }
    }

    public func render(tag: TagContext) throws -> Future<TemplateData> {
        let data = try tag.submissionsData()

        let placeholder = tag.parameters[safe: 1]?.string
        let helpText = tag.parameters[safe: 2]?.string

        let inputData = InputData(
            key: data.key,
            value: data.value,
            label: data.label,
            isRequired: data.isRequired,
            errors: data.errors,
            hasErrors: data.hasErrors,
            placeholder: placeholder,
            helpText: helpText
        )

        return try c(tag, inputData)
    }
}
