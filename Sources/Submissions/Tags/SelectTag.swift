import TemplateKit

/// A tag that renders a template file corresponding to a select input element.
public final class SelectTag: TagRenderer {
    private static let optionIDKey = "id"
    private static let optionValueKey = "value"

    public struct Option: Encodable, TemplateDataRepresentable {
        let id: String
        let value: String

        public func convertToTemplateData() throws -> TemplateData {
            return .dictionary([
                SelectTag.optionIDKey: .string(id),
                SelectTag.optionValueKey: .string(value)
            ])
        }
    }

    struct InputData: Encodable {
        let key: String
        let value: String?
        let options: [Option]
        let label: String?
        let isRequired: Bool
        let errors: [String]
        let hasErrors: Bool
        let placeholder: String?
        let helpText: String?
    }

    /// Create a new `SelectTag`.
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

        let rawOptions = tag.parameters[safe: 1]?.array ?? []
        let options: [Option] = rawOptions.compactMap { data in
            guard
                let id = data.dictionary?[SelectTag.optionIDKey]?.string,
                let value = data.dictionary?[SelectTag.optionValueKey]?.string
            else {
                return nil
            }
            return SelectTag.Option(id: id, value: value)
        }

        let placeholder = tag.parameters[safe: 2]?.string
        let helpText = tag.parameters[safe: 3]?.string

        return (data.errors ?? tag.future([])).flatMap {
            let inputData = InputData(
                key: data.key,
                value: data.value,
                options: options,
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

// MARK: Convenience helpers

/// A type that can be used as an option for the SelectTag.
protocol Selectable {
    func optionID() throws -> String?
    func optionValue() throws -> String?
}

extension Array where Element: Selectable {
    /// Generates the options for the SelectTag.
    var options: [SelectTag.Option] {
        return self.compactMap { option in
            guard
                let id = try? option.optionID(),
                let unwrappedId = id,
                let value = try? option.optionValue(),
                let unwrappedValue = value
            else { return nil }

            return SelectTag.Option(
                id: unwrappedId,
                value: unwrappedValue
            )
        }
    }
}
