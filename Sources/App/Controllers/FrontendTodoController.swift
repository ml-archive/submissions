import Leaf
import Submissions
import Vapor

final class FrontendTodoController {
    func renderAll(req: Request) throws -> Future<View> {
        return Todo.query(on: req).all()
            .flatMap { todos in
                try req.view().render("Todo/all", [
                    "todos": todos
                ])
        }
    }

    func renderCreate(req: Request) throws -> Future<View> {
        try req.populateFields(with: Todo.Submission.empty.makeFields())
        return try req.view().render("Todo/edit")
    }

    func renderEdit(req: Request) throws -> Future<View> {
        return try req.parameters.next(Todo.self)
            .flatMap { todo in
                try req.populateFields(with: Todo.Submission(todo).makeFields())
                return try req.view().render("Todo/edit")
            }
    }

    func create(req: Request) throws -> Future<Response> {
        return try req.content.decode(Todo.Submission.self)
            .flatMap(to: Response.self) { submission in
                switch try submission.makeFields().validate(inContext: .create) {
                case .success:
                    return try req
                        .content.decode(Todo.Create.self)
                        .map(Todo.init)
                        .flatMap { todo in
                            todo.save(on: req)
                        }
                        .transform(to: req.redirect(to: "todos"))
                // TODO: add flash
                case .failure(let error):
                    try req.populateFields(
                        with: submission.makeFields(),
                        andErrors: error.validationErrors
                    )
                    return try req
                        .view().render("Todo/edit")
                        .flatMap { view in
                            view.encode(status: .unprocessableEntity, for: req) // TODO: is this correct?
                    }
                }
            }
    }

    func update(req: Request) throws -> Future<Response> {
        return try req.parameters.next(Todo.self)
            .flatMap(to: Response.self) { todo in
                try req.content.decode(Todo.Submission.self)
                    .flatMap(to: Response.self) { submission in
                        switch try submission.makeFields().validate(inContext: .create) {
                        case .success:
                            todo.update(submission)
                            return todo.save(on: req)
                                .transform(to: req.redirect(to: "todos"))
                        // TODO: add flash
                        case .failure(let error):
                            try req.populateFields(
                                with: submission.makeFields(),
                                andErrors: error.validationErrors
                            )
                            return try req
                                .view().render("Todo/edit")
                                .flatMap { view in
                                    view.encode(status: .unprocessableEntity, for: req) // TODO: is this correct?
                            }
                        }
                    }
            }
    }
}
