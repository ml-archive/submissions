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
            .flatMap { submission in
                try submission
                    .validate(inContext: .create, on: req)
                    .flatMap { _ in
                        try req.content.decode(Todo.Create.self)
                    }
                    .map(Todo.init)
                    .save(on: req)
                    .transform(to: req.redirect(to: "/todos"))
                    .catchFlatMap { error in
                        guard let validationError = error as? SubmissionValidationError else {
                            throw error
                        }
                        try req.populateFields(
                            with: submission.makeFields(),
                            andErrors: validationError.validationErrors
                        )
                        // TODO: add flash
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
            .flatMap { todo in
                try req.content.decode(Todo.Submission.self)
                    .flatMap { submission in
                        try submission
                            .validate(inContext: .update, on: req)
                            .map(to: Todo.self) { _ in
                                todo.update(submission)
                                return todo
                            }
                            .save(on: req)
                            .transform(to: req.redirect(to: "/todos"))
                            .catchFlatMap { error in
                                guard let validationError = error as? SubmissionValidationError else {
                                    throw error
                                }
                                try req.populateFields(
                                    with: submission.makeFields(),
                                    andErrors: validationError.validationErrors
                                )
                                // TODO: add flash
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
