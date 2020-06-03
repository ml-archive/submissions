import Vapor

public protocol RequestMakeable {
    static func make(from request: Request) -> EventLoopFuture<Self>
}

public extension RequestMakeable where Self: Decodable {
    static func make(from request: Request) -> EventLoopFuture<Self> {
        do {
            return request.eventLoop.future(try request.content.decode(Self.self))
        } catch {
            return request.eventLoop.future(error: error)
        }
    }
}
