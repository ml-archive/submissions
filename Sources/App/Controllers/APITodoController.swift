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
            .validate(inContext: .create, on: req)
            .flatMap { _ in
                try req.content.decode(Todo.Create.self)
            }
            .map(Todo.init)
            .save(on: req)
    }

    func update(req: Request) throws -> Future<Todo> {
        return try req.parameters.next(Todo.self)
            .flatMap(to: Todo.self) { todo in
                try req.content.decode(Todo.Submission.self)
                    .validate(inContext: .update, on: req)
                    .map { submission in
                        todo.update(submission)
                        return todo
                    }
            }
            .save(on: req)
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
