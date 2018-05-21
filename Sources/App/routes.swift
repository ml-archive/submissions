import Submissions
import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {

    let api = router.grouped("api")
    let captureValidationErrors = api.grouped(SubmissionValidationErrorMiddleware.self)

    let todoController = TodoController()
    api.get("todos", use: todoController.all)
    api.get("todos", Todo.parameter, use: todoController.single)

    captureValidationErrors.post("todos", use: todoController.create)
    captureValidationErrors.patch("todos", Todo.parameter, use: todoController.update)
    api.delete("todos", Todo.parameter, use: todoController.delete)

    // MARK: Views
    router.get("todos", use: todoController.renderAll)
    router.get("todos/create", use: todoController.renderCreate)
    router.get("todos", Todo.parameter, "edit", use: todoController.renderEdit)
}
