import Vapor

final class MockTemplateRenderer: TemplateRenderer, Service {
    let tags: [String: TagRenderer] = [:]
    let container: Container
    var parser: TemplateParser {
        return self
    }
    var astCache: ASTCache? = nil
    let templateFileEnding = ""
    let relativeDirectory = ""

    init(container: Container) {
        self.container = container
    }

    func render<E>(_ path: String, _ context: E, userInfo: [AnyHashable: Any]) -> Future<View> where E: Encodable {
        let encoder = JSONEncoder()
        let data = try! encoder.encode(EncodableViewData(context: context, path: path))
        let view = View(data: data)
        return container.future(view)
    }
}

extension MockTemplateRenderer: TemplateParser {
    func parse(scanner: TemplateByteScanner) throws -> [TemplateSyntax] {
        return []
    }
}

struct EncodableViewData<E: Encodable>: Encodable {
    let context: E
    let path: String
}

struct DecodableViewData<D: Decodable>: Decodable {
    let context: D
    let path: String
}

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
