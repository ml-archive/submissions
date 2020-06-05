import Vapor

public protocol UpdateRequest: RequestMakeable {
    associatedtype Model

    static func find(on request: Request) -> EventLoopFuture<Model>
    static func validations(for model: Model, on request: Request) -> EventLoopFuture<Validations>

    func update(_ model: Model, on request: Request) -> EventLoopFuture<Model>
}

public extension UpdateRequest {
    static func validations(
        for _: Model,
        on request: Request
    ) -> EventLoopFuture<Validations> {
        request.eventLoop.future(Validations())
    }
}

public extension UpdateRequest {
    static func update(on request: Request) -> EventLoopFuture<Model> {
        find(on: request).flatMap { model in
            validations(for: model, on: request).flatMapThrowing { validations in
                try validations.validate(request).assert()
            }.flatMap {
                make(from: request)
            }.flatMap {
                $0.update(model, on: request)
            }
        }
    }
}

public extension UpdateRequest where Model: Authenticatable {
    static func create(on request: Request) -> EventLoopFuture<Model> {
        do {
            return request.eventLoop.future(try request.auth.require())
        } catch {
            return request.eventLoop.makeFailedFuture(error)
        }
    }
}
