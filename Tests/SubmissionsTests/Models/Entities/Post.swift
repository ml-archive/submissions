import Vapor

final class Post: Content {
    var title: String
    
    init(title: String) {
        self.title = title
    }
}
