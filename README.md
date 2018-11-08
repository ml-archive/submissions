# Submissions 📩
[![Swift Version](https://img.shields.io/badge/Swift-4.1-brightgreen.svg)](http://swift.org)
[![Vapor Version](https://img.shields.io/badge/Vapor-3-30B6FC.svg)](http://vapor.codes)
[![CircleCI](https://circleci.com/gh/nodes-vapor/submissions/tree/master.svg?style=svg)](https://circleci.com/gh/nodes-vapor/submissions/tree/master)
[![codebeat badge](https://codebeat.co/badges/b9c894d6-8c6a-4a07-bfd5-29db898c8dfe)](https://codebeat.co/projects/github-com-nodes-vapor-submissions-master)
[![codecov](https://codecov.io/gh/nodes-vapor/submissions/branch/master/graph/badge.svg)](https://codecov.io/gh/nodes-vapor/submissions)
[![Readme Score](http://readme-score-api.herokuapp.com/score.svg?url=https://github.com/nodes-vapor/submissions)](http://clayallsopp.github.io/readme-score?url=https://github.com/nodes-vapor/submissions)
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/nodes-vapor/reset/master/LICENSE)

# Installation

## Package.swift

Add `Submissions` to the Package dependencies:
```swift
dependencies: [
    ...,
    .package(url: "https://github.com/nodes-vapor/submissions.git", from: "1.0.0-beta")
]
```

as well as to your target (e.g. "App"):

```swift
targets: [
    ...
    .target(
        name: "App",
        dependencies: [... "Submissions" ...]
    ),
    ...
]
```

Next, copy/paste the `Resources/Views/Submissions` folder into your project in order to be able to use the provided Leaf tags. These files can be changed as explained in the [Leaf Tags](#leaf-tags) section, however it's recommended to copy this folder to your project anyway. This makes it easier for you to keep track of updates and your project will work if you decide later on to not use your own customized leaf files.

> Right now the provided Leaf templates are depending on the [Bootstrap package](https://github.com/nodes-vapor/bootstrap). This will change in the future. For the moment, the consumer of this package will need to include Bootstrap and adapt the provided leaf files or replace them entirely.

## Introduction

Submissions was written to minimize the amount of boilerplate needed to write the common tasks of rendering forms and processing and validating data from POST and PATCH requests. Submissions makes it easy to present detailed validation errors for web users as well as API consumers.

## Getting started 🚀

First make sure that you've imported Submissions everywhere it's needed:

```swift
import Submissions
```

### Adding the Provider

"Submissions" comes with a light-weight provider that we'll need to register in the `configure` function in our `configure.swift` file:

```swift
try services.register(SubmissionsProvider())
```

This makes sure that fields and errors can be stored on the request using a `FieldCache` service.

### Adding the Leaf tag

#### Using a shared Leaf tag config

This package supports using a shared Leaf tag config which removes the task of registering the tags from the consumer of this package. Please see [this description](https://github.com/nodes-vapor/sugar#mutable-leaf-tag-config) if you want to use this.

#### Manually registering the Leaf tag(s)

```swift
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    let provider = SubmissionsProvider()
    services.register(SubmissionsProvider())
    let paths = provider.config.tagTemplatePaths

    services.register { _ -> LeafTagConfig in
        var tags = LeafTagConfig.default()
        tags.use([
            "submissions:email": InputTag(templatePath: paths.emailField),
            "submissions:password": InputTag(templatePath: paths.passwordField),
            "submissions:text": InputTag(templatePath: paths.textField),
            "submissions:hidden": InputTag(templatePath: paths.hiddenField),
            "submissions:textarea": InputTag(templatePath: paths.textareaField),
            "submissions:checkbox": InputTag(templatePath: paths.checkboxField)
        ])

        return tags
    }
}
```

If you want to fully customize the way the input groups are being generated, you are free to override the Leaf paths for the input group when setting up the provider by supplying your own `SubmissionsConfig`.

## Making a Submittable model

Let's take a simple Todo class as an example.

```swift
final class Todo: Model, Content, Parameter {
    var title: String

    init(id: Int? = nil, title: String) {
        self.id = id
        self.title = title
    }
}
```

Let's conform our model to `Submittable`. This means we need to associate our model with a type that can be used to validate requests to create or update instances of our model.

```swift 
import Submissions

extension Todo: Submittable {
    struct Submission: SubmissionType {
        let title: String?
    }
}
```

This type is decoded from the request. In order for missing values to result in validation errors (instead of a decoding error) all properties need to be optional. We'll rely on our validation (see below) to catch any missing fields.

Next we'll see how we can associate validators (and labels) with our fields. 

```swift
extension Todo.Submission {
    func fieldEntries() throws -> [FieldEntry] {
        return try [
            makeFieldEntry(keyPath: \.title, label: "Title", validators: [.count(5...)], isRequired: true)
        ]
    }

    ...
```

Using the `makeFieldEntry` helper function we can use type-safe `KeyPath`s to refer to the values in our `Submission` struct. In addition to the list of validators it is possible to supply `asyncValidators` which is a list of closures that performs async validation. This can be useful when validation requires a call to the database for instance. See the API docs for further information. If `isRequired` is set to `false` then the field will accept `nil` and `""` (the empty string) as values. Otherwise, you can specify the `absentValueStrategy` to make it behave as you expect.

The submission type is also used by tags to render labels and any existing values for input fields in a form. Therefore we'll need to provide a way to create a `Submission` value from a todo, or `nil` in case we're creating a new one.

```swift
    // Todo.Submission, continued ...

    init(_ todo: Todo?) {
        title = todo?.title
    }
}
```

After validation the `Submission` value can be used to update our model.

```swift
// Todo: Submittable, continued ...

func update(_ submission: Submission) {
    if let title = submission.title {
        self.title = title
    }
}
```

Creating a new instance of our `Todo` model works slightly differently. We'll need to define another type that can be used to create our models.

```swift
    // extension Todo: Submittable continued

    struct Create: Decodable {
        let title: String
    }

    convenience init(_ create: Create) {
        self.init(id: nil, title: create.title)
    }
```

The way this works is that after decoding and validating the `Submission` value, a value of the `Create` type will be decoded from the same request. It is our duty to make sure that all non-optional properties in the `Create` type have corresponding validators in the `Submission` type. This prevents that errors will be thrown during decoding when fields are missing.

### Validating API requests

Let's create a controller for our Todo related API routes.

```swift
final class APITodoController {
    ...
}
```

in your `routes.swift` add:
```swift
// in func routes
...
let api = router.grouped("api")
let apiTodoController = APITodoController()
// add api routes here
...
```

We'll add the a create route to our `APITodoController:

```swift
func create(req: Request) throws -> Future<Either<Todo, SubmissionValidationError>> {
    return try req.content.decode(Todo.Submission.self)
        .createValid(on: req)
        .save(on: req)
        .promoteErrors()
}
```

and register it as a POST request in `routes.swift`:

```swift
api.post("todos", use: apiTodoController.create)
```

In the route we decode our `Submission` value, we validate it and create a Todo item (using `createValid`) before we save it. With `promoteErrors`, in combination with the return type `Future<Either<Todo, SubmissionValidationError>>`, we can "promote" validation errors to values meaning we can create a proper response out of them. Since both `Todo` and `SubmissionValidationError` conform to `ResponseEncodable`, so does `Either` through the power of conditional conformance. In case of a validation error the response will be:

```json
{
  "error": true,
  "validationErrors": {
    "title": [
      "data is not larger than 5"
    ]
  },
  "reason": "One or more fields failed to pass validation."
}
```

Updating an existing instance follows a similar path. Let's add the following function to our APITodoController.

```swift
func update(req: Request) throws -> Future<Either<Todo, SubmissionValidationError>> {
    return try req.parameters.next(Todo.self)
        .updateValid(on: req)
        .save(on: req)
        .promoteErrors()
}
```

and register it as a PATCH request in `routes.swift`:

```swift
api.patch("todos", Todo.parameter, use: apiTodoController.update)
```

## Validating HTML form requests

### Leaf Tags

When building your HTML form using Leaf you can add inputs for your model's fields like so:

```
#submissions:text("title", "Enter title", "Please enter a title")
```

This will render a form group with an input and any errors stored in the field cache for the "title" field. This produces the following Bootstrap 4 style HTML (with in this case a validation error):

```html
<div class="form-group">
    <label for="title">Title</label>
    <input type="text" class="form-control is-invalid" id="title" name="title" value="four" placeholder="Enter title">
    <small id="titleHelp" class="form-text text-muted">Please enter a title</small>
    <div class="invalid-feedback"><div>data is not larger than 5</div></div>
</div>
```

> Note: Currently only "text", "email", "pasword" and "textarea" are supported.

### Rendering the forms

Now we'll create a controller for the frontend routes.

```swift
final class FrontendTodoController {
    ...
}
```

in your `routes.swift` we'll add:
```swift
// in func routes
...
let frontendTodoController = FrontendTodoController()
// add frontend routes here
...
```

An empty form can be created by populating the fields using the `Submittable` type before rendering the view.

```swift
func renderCreate(req: Request) throws -> Future<View> {
    try req.populateFields(Todo.self)
    return try req.privateContainer.make(LeafRenderer.self).render("Todo/edit")
}
```

and in `routes.swift` we'll add:
```swift
router.get("todos/create", use: frontendTodoController.renderCreate)
```

> Note how we're using the `privateContainer` on the `Request` since that is where the field cache is registered. This is done to ensure the field cache does not outlive the request.

In order to populate the fields with the values of an existing entity we need to first load our entity and put its values in the field cache like so.

```swift
func renderEdit(req: Request) throws -> Future<View> {
    return try req.parameters.next(Todo.self)
        .populateFields(on: req)
        .flatMap { _ in
            try req.privateContainer.make(LeafRenderer.self).render("Todo/edit")
        }
}
```

In `routes.swift`:
```swift
router.get("todos", Todo.parameter, "edit", use: frontendTodoController.renderEdit)
```

> It is also possible to populate the fields for the form directly using an (optional) instance:
>```swift
>let todo: Todo? = ... // e.g. from a database query
>req.populateFields(todo)
>```
>If the value is `nil` it will have the same effect as calling `req.populateFields(Todo.self)`.

### Validating and storing the data

Creating a new `Todo` is very similar to how we do in the API routes except that now we'll redirect on success and handle the error a bit differently (see below).

```swift
func create(req: Request) throws -> Future<Response> {
    return try req.content.decode(Todo.Submission.self)
        .createValid(on: req)
        .save(on: req)
        .transform(to: req.redirect(to: "/todos"))
        .catchFlatMap(handleCreateOrUpdateError(on: req))
}
```

and in `routes.swift` we'll add:

```swift
router.post("todos/create", use: frontendTodoController.create)
```

Updating should now also look familiar.

```swift
func update(req: Request) throws -> Future<Response> {
    return try req.parameters.next(Todo.self)
        .updateValid(on: req)
        .save(on: req)
        .transform(to: req.redirect(to: "/todos"))
        .catchFlatMap(handleCreateOrUpdateError(on: req))
}
```

In `routes.swift`:
```swift
router.post("todos", Todo.parameter, "edit", use: frontendTodoController.update)
```

One way to deal with errors is to render the edit view again which will now show all validation errors for all fields.

```swift
func handleCreateOrUpdateError(on req: Request) -> (Error) throws -> Future<Response> {
    return { _ in
        try req
            .privateContainer
            .make(LeafRenderer.self)
            .render("Todo/edit")
            .flatMap { view in
                try view.encode(for: req)
            }
    }
}
```

## 🏆 Credits

This package is developed and maintained by the Vapor team at [Nodes](https://www.nodesagency.com).
The package owner for this project is [Siemen](https://github.com/siemensikkema).

## 📄 License

This package is open-sourced software licensed under the [MIT license](http://opensource.org/licenses/MIT).
