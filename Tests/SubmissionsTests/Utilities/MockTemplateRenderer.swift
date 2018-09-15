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
