import Vapor

public protocol RequestMakeable {
    static func make(from request: Request) -> EventLoopFuture<Self>
}

public extension RequestMakeable where Self: Decodable {
    static func make(from request: Request) -> EventLoopFuture<Self> {
        request.eventLoop.future(result: .init { try request.content.decode(Self.self) })
    }
}
