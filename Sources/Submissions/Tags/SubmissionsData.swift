import TemplateKit

public extension TagContext {

    /// Encapsulates relevant submissions data that can be used for validation output.
    /// For example when rendering the form.
    public struct SubmissionsData: Encodable {
        public let key: String
        public let value: String?
        public let label: String?
        public let isRequired: Bool
        public let errors: Future<[String]>?
    }

    /// Pulls out any relevant submissions data for the given field using the `FieldCache`.
    ///
    /// - Returns: The submission data related to the given field.
    /// - Throws: When the name of the field is missing.
    public func submissionsData() throws -> SubmissionsData {
        let fieldCache = try requireRequest().fieldCache()

        guard let key = parameters[safe: 0]?.string else {
            throw error(reason: "Invalid parameter type.")
        }

        // Vapor's `URLEncodedFormDecoder` requires array-valued arguments to be encoded with a trailing `[]` in the
        // form data. However, key paths can't contain `[]`, so we strip that part when searching for a tag's field.
        let keyPath = key.components(separatedBy: "[]")[0]
        let field = fieldCache[valueFor: keyPath]
        let errors = fieldCache[errorsFor: keyPath]

        return SubmissionsData(
            key: key,
            value: field?.value,
            label: field?.label,
            isRequired: field?.isRequired ?? false,
            errors: errors
        )
    }
}
