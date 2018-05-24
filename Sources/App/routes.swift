import Submissions
import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {

    let api = router.grouped("api")
    let captureValidationErrors = api.grouped(SubmissionValidationErrorMiddleware.self)

    let apiTodoController = APITodoController()
    api.get("todos", use: apiTodoController.all)
    api.get("todos", Todo.parameter, use: apiTodoController.single)

    captureValidationErrors.post("todos", use: apiTodoController.create)
    captureValidationErrors.patch("todos", Todo.parameter, use: apiTodoController.update)
    api.delete("todos", Todo.parameter, use: apiTodoController.delete)

    let frontendTodoController = FrontendTodoController()
    router.get("todos", use: frontendTodoController.renderAll)

    router.get ("todos/create", use: frontendTodoController.renderCreate)
    router.post("todos/create", use: frontendTodoController.create)

    router.get ("todos", Todo.parameter, "edit", use: frontendTodoController.renderEdit)
    router.post("todos", Todo.parameter, "edit", use: frontendTodoController.update)
}
