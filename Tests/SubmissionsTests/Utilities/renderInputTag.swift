import Submissions
import Vapor
import XCTest

func renderInputTag(
    templatePath: String = "",
    key: String = "",
    placeholder: String? = nil,
    helpText: String? = nil,
    modifyRequest: (Request) throws -> Void = { _ in }
) throws -> (String, TagContextData) {
    let req = try Request.test()
    try modifyRequest(req)

    let inputTag = InputTag(templatePath: templatePath)

    var parameters: [TemplateData] = [.string(key)]
    if let placeholder = placeholder {
        parameters.append(.string(placeholder))
    }
    if let helpText = helpText {
        parameters.append(.string(helpText))
    }

    let context = TemplateDataContext(data: .dictionary([:]))
    let tagContext = TagContext(
        name: "",
        parameters: parameters,
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
    let renderedViewData = try decoder.decode(DecodableViewData<TagContextData>.self, from: data)
    return (renderedViewData.path, renderedViewData.context)
}
