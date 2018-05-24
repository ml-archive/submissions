import Vapor

final class APITodoController {
    func all(req: Request) -> Future<[Todo]> {
        return Todo.query(on: req).all()
    }

    func single(req: Request) throws -> Future<Todo> {
        return try req.parameters.next(Todo.self)
    }

    func create(req: Request) throws -> Future<Todo> {
        return try req.content.decode(Todo.Submission.self)
            .flatMap(to: Todo.Create.self) { submission in
                switch try submission.makeFields().validate(inContext: .create) {
                case .success: return try req.content.decode(Todo.Create.self)
                case .failure(let error): throw error
                }
            }
            .map(Todo.init)
    }

    func update(req: Request) throws -> Future<Todo> {
        return try req.parameters.next(Todo.self)
            .flatMap { todo in
                try req.content.decode(Todo.Submission.self)
                    .flatMap { submission in
                        switch try submission.makeFields().validate(inContext: .create) {
                        case .success:
                            todo.update(submission)
                            return todo.save(on: req)
                        case .failure(let error): throw error
                        }
                    }
            }
    }

    func delete(req: Request) throws -> Future<HTTPStatus> {
        return try req
            .parameters
            .next(Todo.self)
            .flatMap { todo in
                return todo.delete(on: req)
            }
            .transform(to: .ok)
    }
}
