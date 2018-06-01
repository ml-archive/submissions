import Leaf

public extension TagContext {
    struct SubmissionsData: Encodable {
        let key: String
        let value: String?
        let label: String?
        let isRequired: Bool
        let errors: [String]
        let hasErrors: Bool
    }

    public func submissionsData() throws -> SubmissionsData {
        let fieldCache = try container.make(FieldCache.self)

        guard let key = parameters[safe: 0]?.string else {
            throw error(reason: "Invalid parameter type.")
        }

        let field = fieldCache[valueFor: key]
        let errors = fieldCache[errorsFor: key]

        return SubmissionsData(
            key: key,
            value: field?.value,
            label: field?.label,
            isRequired: field?.isRequired ?? false,
            errors: errors,
            hasErrors: errors.count > 0
        )
    }
}
