import Vapor

final class TodoController {
    func all(req: Request) throws -> Future<[Todo]> {
        return Todo.query(on: req).all()
    }

    func single(req: Request) throws -> Future<Todo> {
        return try req.parameters.next(Todo.self)
    }

    func create(req: Request) throws -> Future<Todo> {
        return try req
            .content
            .createValid(Todo.self)
            .flatMap { todo in
                todo.save(on: req)
            }
    }

    func update(req: Request) throws -> Future<Todo> {
        return try req
            .parameters
            .next(Todo.self)
            .flatMap { todo in
                try req.content.updateValid(todo)
            }
            .flatMap { todo in
                todo.save(on: req)
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

import Leaf
import Submissions

extension TodoController {
    func renderAll(req: Request) throws -> Future<View> {
        return try all(req: req)
            .flatMap { todos in
                try req.view().render("Todo/all", [
                    "todos": todos
                ])
        }
    }

    func renderCreate(req: Request) throws -> Future<View> {
        try req.populateFields(from: Todo.self)
        return try req.view().render("Todo/edit")
    }

    func renderEdit(req: Request) throws -> Future<View> {
        return try single(req: req)
            .flatMap { todo in
                try req.populateFields(from: todo)
                return try req.view().render("Todo/edit")
            }
    }

    // TODO: make store endpoint that validates and either returns to index or shows errors using fieldCache
}
