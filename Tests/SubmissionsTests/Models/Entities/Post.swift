import Vapor

struct Post: Content {
    let id = UUID()
    let title: String
}
