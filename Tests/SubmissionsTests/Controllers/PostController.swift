import Submissions
import Vapor

struct PostController {
    func create(request: Request) -> EventLoopFuture<Post> {
        CreatePostRequest.create(on: request)
    }

    func update(request: Request) -> EventLoopFuture<Post> {
        //find the post
        let post = Post(title: "")
        //and update it
        return UpdatePostRequest.update(post, on: request)
    }
}

extension PostController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.post("posts", use: create)
        routes.put("posts", use: update)
    }
}
