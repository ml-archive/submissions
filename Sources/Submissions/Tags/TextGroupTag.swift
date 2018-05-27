import Leaf

/// A tag that renders an form-group with a text input. Includes a label and errors if supplied.
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

        let html = """
        <div class='form-group\(hasErrors ? " has-error" : "")'>
            \(field?.label.map { "<label class='control-label' for=\(key)>\($0)</label>" } ?? "")
            <input type='text' name=\(key) value=\(field?.value ?? "")>
            \(errors.map { "<span class='help-block'>\($0)</span>" }.joined())
        </div>
        """

        return tag.future(.string(html))
    }
}
