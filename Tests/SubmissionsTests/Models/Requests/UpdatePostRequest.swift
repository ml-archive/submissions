import Vapor
import Submissions

struct UpdatePostRequest: Content, UpdateRequest {
    let title: String?

    static func validations(for model: Post, on request: Request) -> EventLoopFuture<Validations> {
        var validations = Validations()
        if request.url.query == "fail" {
            validations.add("validation", result: ValidatorResults.TestFailure())
        }
        return request.eventLoop.future(validations)
    }

    func update(_ post: Post, on request: Request) -> EventLoopFuture<Post> {
        if let title = title {
            post.title = title
        }
        return request.eventLoop.future(post)
    }
}
