@testable import Submissions
import Vapor
import XCTest

final class SubmissionsTests: XCTestCase {
    func testRenderFieldsInFormFromType() throws {
        var services = Services()
        services.register(FieldCache())
        let app = try Application(environment: .testing, services: services)
        let req = Request(using: app)

        var inputData: InputTag.InputData!
        let inputTag = InputTag { tagContext, _inputData in
            inputData = _inputData
            let templateData = TemplateData.bool(true)
            return tagContext.future(templateData)
        }

        let key = "key"
        let placeholder = "placeholder"
        let helpText = "helpText"

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

        XCTAssertEqual(templateData, .bool(true))
        XCTAssertEqual(inputData.key, key)
        XCTAssertNil(inputData.value)
        XCTAssertNil(inputData.label)
        XCTAssertFalse(inputData.isRequired)
        XCTAssertEqual(inputData.errors, [])
        XCTAssertEqual(inputData.hasErrors, false)
        XCTAssertEqual(inputData.placeholder, placeholder)
        XCTAssertEqual(inputData.helpText, helpText)
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
