@testable import Submissions
import Vapor
import XCTest

struct EncodableViewData<E: Encodable>: Encodable {
    let context: E
    let path: String
}

struct DecodableViewData<D: Decodable>: Decodable {
    let context: D
    let path: String
}

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

struct MockInputData: Decodable {
    let key: String
    let value: String?
    let label: String?
    let isRequired: Bool
    let errors: [String]
    let hasErrors: Bool
    let placeholder: String?
    let helpText: String?
}

final class SubmissionsTests: XCTestCase {
    func renderInputTag(
        templatePath: String,
        key: String,
        placeholder: String,
        helpText: String
    ) throws -> (String, MockInputData) {
        var services = Services()
        services.register(FieldCache())
        services.register(TemplateRenderer.self) { container in
            MockTemplateRenderer(container: container)
        }
        let app = try Application(environment: .testing, services: services)
        let req = Request(using: app)

        let inputTag = InputTag(templatePath: templatePath)

        let context = TemplateDataContext(data: .dictionary([:]))
        let tagContext = TagContext(
            name: "", parameters: [.string(key), .string(placeholder), .string(helpText)],
            body: nil,
            source: TemplateSource(file: "", line: 0, column: 0, range: 0..<1),
            context: context,
            serializer: TemplateSerializer(
                renderer: PlaintextRenderer(viewsDir: "", on: req),
                context: context,
                using: req
            ),
            using: req
        )
        tagContext.request = req
        let templateData = try inputTag.render(tag: tagContext).wait()

        guard let data = templateData.data else {
            XCTFail("TemplateData contains no data")
            assert(false)
        }
        let decoder = JSONDecoder()
        let renderedViewData = try decoder.decode(DecodableViewData<MockInputData>.self, from: data)
        return (renderedViewData.path, renderedViewData.context)
    }

    func testRenderInputTagWithEmptyFieldCache() throws {
        let (path, templateContext) = try renderInputTag(
            templatePath: "path",
            key: "key",
            placeholder: "placeholder",
            helpText: "helpText"
        )

        XCTAssertEqual(templateContext.key, "key")
        XCTAssertNil(templateContext.value)
        XCTAssertNil(templateContext.label)
        XCTAssertFalse(templateContext.isRequired)
        XCTAssertEqual(templateContext.errors, [])
        XCTAssertEqual(templateContext.hasErrors, false)
        XCTAssertEqual(templateContext.placeholder, "placeholder")
        XCTAssertEqual(templateContext.helpText, "helpText")

        XCTAssertEqual(path, "path")
    }

    func testRenderFieldsInFormFromType() throws {
    }

    func testRenderFieldsInFormFromInstance() {

    }

    func testValidationFromForm() {

    }

    func testValidationFromAPI() {

    }

    func testSuccessfulValidationAPIResponse() {

    }

    func testFailedValidationAPIResponse() {

    }
}
