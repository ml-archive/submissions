import Leaf

final class InputTag: TagRenderer {
    enum Keys: String {
        case text = "text"
        case email = "email"
        case password = "password"
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
        var type = Keys.text
        let placeholder = tag.parameters[safe: 2]?.string
        let helpText = tag.parameters[safe: 3]?.string

        if
            let providedType = tag.parameters[safe: 1]?.string,
            let parsedType = Keys(rawValue: providedType)
        {
            type = parsedType
        }

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

        return leaf.render(config.viewPaths.fromTagType(type), viewData)
            .map(to: TemplateData.self) { view in
                .string(String(bytes: view.data, encoding: .utf8) ?? "")
            }
    }
}

private extension SubmissionsViewPaths {
    func fromTagType(_ key: InputTag.Keys) -> String {
        switch key {
        case .text: return self.textField
        case .email: return self.emailField
        case .password: return self.passwordField
        }
    }
}
