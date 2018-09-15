import Submissions
import Vapor

extension Request {
    static func test() throws -> Request {
        var config = Config()
        config.prefer(MockTemplateRenderer.self, for: TemplateRenderer.self)

        var services = Services()
        try services.register(SubmissionsProvider())
        services.register(ContentConfig.self)
        services.register(ContentCoders.self)
        services.register(TemplateRenderer.self) { container in
            MockTemplateRenderer(container: container)
        }
        let app = try Application(config: config, environment: .testing, services: services)
        return Request(using: app)
    }
}
