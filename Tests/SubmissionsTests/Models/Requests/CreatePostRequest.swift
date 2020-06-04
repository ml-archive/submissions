import Vapor
import Submissions

struct CreatePostRequest: Content, CreateRequest {
    typealias Model = Post

    func create(on request: Request) -> EventLoopFuture<Post> {
        do {
            let post = try request.content.decode(Post.self)
            // add code here that creates a new post into the database
            return request.eventLoop.future(post)
        } catch(let error) {
            return request.eventLoop.makeFailedFuture(error)
        }
    }

    static func validations(on request: Request) -> EventLoopFuture<Validations> {
        var validations = Validations()
        if request.url.query == "fail" {
            validations.add("validation", result: ValidatorResults.TestFailure())
        }
        return request.eventLoop.future(validations)
    }
}
