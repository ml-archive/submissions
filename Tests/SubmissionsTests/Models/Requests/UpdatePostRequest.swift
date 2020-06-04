import Vapor
import Submissions

struct UpdatePostRequest: Content, UpdateRequest {
    typealias Model = Post

    static func validations(for model: Post, on request: Request) -> EventLoopFuture<Validations> {
        validations(on: request)
    }

    func update(_ model: Post, on request: Request) -> EventLoopFuture<Post> {
        do {
            let post = try request.content.decode(Post.self)
            // add code here that saves the updated post into the database
            return request.eventLoop.future(post)
        } catch(let error) {
            return request.eventLoop.makeFailedFuture(error)
        }
    }
}
