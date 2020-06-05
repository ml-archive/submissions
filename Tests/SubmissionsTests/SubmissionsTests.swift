import XCTVapor

final class SubmissionsTests: XCTestCase {
    var app: Application!

    override func setUp() {
        app = Application(.testing)
        try! app.register(collection: PostController())
    }

    override func tearDown() {
        app.shutdown()
        app = nil
    }

    func test_create() throws {
        try app.test(.POST, "posts", beforeRequest: { request in
            try request.content.encode(["title": "Some title"], as: .json)
        }) { response in
            XCTAssertEqual(response.status, .ok)

            // test post response
            let post = try response.content.decode(Post.self)
            XCTAssertEqual(post.title, "Some title")
        }
    }

    func test_create_includesValidation() throws {
        try app.test(.POST, "posts?fail", beforeRequest: { request in
            try request.content.encode(["title": "Some title"], as: .json)
        }) { response in
            XCTAssertEqual(response.status, .badRequest)
    
            let errorReason: String = try response.content.get(at: "reason")
            XCTAssertEqual(errorReason, "validation has failed")
        }
    }

    func test_update() throws {
        try app.test(.PUT, "posts", beforeRequest: { request in
            try request.content.encode(["title": "Updated title"], as: .json)
        }) { response in
            XCTAssertEqual(response.status, .ok)

            // test post response
            let post = try response.content.decode(Post.self)
            XCTAssertEqual(post.title, "Updated title")
        }
    }

    func test_update_includesValidations() throws {
        try app.test(.PUT, "posts?fail", beforeRequest: { request in
            try request.content.encode(["title": "Updated title"], as: .json)
        }) { response in
            XCTAssertEqual(response.status, .badRequest)

            let errorReason: String = try response.content.get(at: "reason")
            XCTAssertEqual(errorReason, "validation has failed")
        }
    }
}
