struct TagContextData: Decodable, Equatable {
    let key: String
    let value: String?
    let label: String?
    let isRequired: Bool
    let errors: [String]
    let hasErrors: Bool
    let placeholder: String?
    let helpText: String?

    init(
        key: String = "",
        value: String? = nil,
        label: String? = nil,
        isRequired: Bool = false,
        errors: [String] = [],
        hasErrors: Bool = false,
        placeholder: String? = nil,
        helpText: String? = nil
    ) {
        self.key = key
        self.value = value
        self.label = label
        self.isRequired = isRequired
        self.errors = errors
        self.hasErrors = hasErrors
        self.placeholder = placeholder
        self.helpText = helpText
    }
}
