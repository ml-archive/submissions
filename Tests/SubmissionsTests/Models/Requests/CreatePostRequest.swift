import Vapor
import Submissions

struct CreatePostRequest: Content, CreateRequest {
    let title: String

    func create(on request: Request) -> EventLoopFuture<Post> {
        request.eventLoop.future(Post(title: title)) 
    }

    static func validations(on request: Request) -> EventLoopFuture<Validations> {
        var validations = Validations()
        if request.url.query == "fail" {
            validations.add("validation", result: ValidatorResults.TestFailure())
        }
        return request.eventLoop.future(validations)
    }
}
