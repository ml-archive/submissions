import Leaf

enum TagError: Error {
    case couldNotFindFieldsetEntry
}

final class TextGroupTag: TagRenderer {
    func render(tag: TagContext) throws -> Future<TemplateData> {
        try tag.requireParameterCount(1)
        let fieldCache = try tag.container.make(FieldCache.self)
        guard
            let key = tag.parameters[0].string,
            let field = fieldCache[valueFor: key]
        else {
            throw TagError.couldNotFindFieldsetEntry
        }

        let errors = fieldCache[errorFor: key]
        let hasErrors = errors.count > 0

        let html = """
        <div class='form-group\(hasErrors ? " has-error" : "")'>
            \(field.label.map { "<label class='control-label' for=\(key)>\($0)</label>" } ?? "")
            <input type='text' name=\(key) value=\(field.stringValue ?? "") />
            \(errors.map { "<span class='help-block'>\($0)</span>" }.joined())
        </div>
        """
        return Future.map(on: tag) {
            return .string(html)
        }
    }
}
