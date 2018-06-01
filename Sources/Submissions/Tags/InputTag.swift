import Leaf

final class InputTag: TagRenderer {
    enum Keys: String {
        case text
        case email
        case password
    }

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

    func render(tag: TagContext) throws -> Future<TemplateData> {
        let data = try tag.submissionsData()

        let config = try tag.container.make(SubmissionsConfig.self)
        let leaf = try tag.container.make(LeafRenderer.self)

        let type = tag.parameters[safe: 1]?.string.flatMap(Keys.init(rawValue:)) ?? .text
        let placeholder = tag.parameters[safe: 2]?.string
        let helpText = tag.parameters[safe: 3]?.string

        let viewData = InputData(
            key: data.key,
            value: data.value,
            label: data.label,
            isRequired: data.isRequired,
            errors: data.errors,
            hasErrors: data.hasErrors,
            placeholder: placeholder,
            helpText: helpText
        )

        return leaf
            .render(config.viewPaths.fromTagType(type), viewData)
            .map { .data($0.data) }
    }
}

private extension SubmissionsViewPaths {
    func fromTagType(_ key: InputTag.Keys) -> String {
        switch key {
        case .text: return textField
        case .email: return emailField
        case .password: return passwordField
        }
    }
}
