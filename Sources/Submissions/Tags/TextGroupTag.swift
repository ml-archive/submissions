import Leaf

/// A tag that renders an form-group with a text input as Bootstrap 4 HTML.
/// Includes a label and errors if supplied.
final class TextGroupTag: TagRenderer {

    /// See `TagRenderer`
    ///
    /// - Parameter tag: The tag context. Must contain 1 string parameter with the key that
    ///   corresponds to a value and possible errors in the field cache.
    /// - Throws: Any error fetching the field cache or when the parameters are invalid.
    func render(tag: TagContext) throws -> Future<TemplateData> {
        try tag.requireParameterCount(1)
        let fieldCache = try tag.container.fieldCache()

        guard let key = tag.parameters[0].string else {
            throw tag.error(reason: "Invalid parameter type.")
        }

        let field = fieldCache[valueFor: key]
        let errors = fieldCache[errorsFor: key]
        let hasErrors = errors.count > 0

        let label = field?.label.map { "<label class='control-label' for=\(key)>\($0)</label>" } ?? ""
        let value = field?.value.map { " value='\($0)'" } ?? ""
        let required = (field?.isRequired ?? false) ? " required" : ""
        let inputClass = "class='form-control\(hasErrors ? " is-invalid" : "")'"
        let input = "<input type='text' \(inputClass) id='\(key)' name='\(key)'\(value)\(required)>"
        let errorBlock = hasErrors ?
            "<div class='invalid-feedback'>\(errors.map { "<div>\($0)</div>" }.joined())</div>" : ""

        let html = "<div>\(label)\(input)\(errorBlock)</div>"

        return tag.future(.string(html))
    }
}
