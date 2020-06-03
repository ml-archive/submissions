# Submissions 📩
[![Swift Version](https://img.shields.io/badge/Swift-5.2-brightgreen.svg)](http://swift.org)
[![Vapor Version](https://img.shields.io/badge/Vapor-4.0-30B6FC.svg)](http://vapor.codes)
[![![codebeat badge](https://codebeat.co/badges/b9c894d6-8c6a-4a07-bfd5-29db898c8dfe)](https://codebeat.co/projects/github-com-nodes-vapor-submissions-master)
[![codecov](https://codecov.io/gh/nodes-vapor/submissions/branch/master/graph/badge.svg)](https://codecov.io/gh/nodes-vapor/submissions)
[![Readme Score](http://readme-score-api.herokuapp.com/score.svg?url=https://github.com/nodes-vapor/submissions)](http://clayallsopp.github.io/readme-score?url=https://github.com/nodes-vapor/submissions)
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/nodes-vapor/reset/master/LICENSE)

# Installation

## Package.swift

Add `Submissions` to the Package dependencies:
```swift
dependencies: [
    ...,
    .package(url: "https://github.com/nodes-vapor/submissions.git", from: "3.0.0")
]
```

as well as to your target (e.g. "App"):

```swift
targets: [
    ...
    .target(
        name: "App",
        dependencies: [
            ...
            .product(name: "Submissions", package: "submissions")
        ]
    ),
    ...
]
```

## Introduction

Submissions was written to reduce the amount of boilerplate needed to write the common tasks of rendering forms and processing and validating data from POST/PUT/PATCH requests (PPP-request, or _submission_ for short). Submissions makes it easy to present detailed validation errors for web users as well as API consumers.

Submissions is designed to be flexible. Its functionality is based around `Field`s which are abstractions that model the parts of a _submission_. 

single values with its validators and meta data such as a label. Usually a form or API request involves multiple properties comprising a model. This can be modeled using multiple `Field`s.

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

## Validating API requests

_TODO_

## Validating HTML form requests

Submissions comes with leaf tags that can render fields into HTML. The leaf files needs to be copied from the folder `Resources/Views/Submissions` from `Submissions` to your project's `Resources/Views`. Then we can register Submissions' leaf tags where you register your other leaf tags, for instance:

```swift
var leafTagConfig = LeafTagConfig.default()
...
leafTagConfig.useSubmissionsLeafTags()
services.register(leafTagConfig)
```

You can customize where Submissions looks for the leaf tags by passing in a modified instance of `TagTemplatePaths` to `useSubmissionsLeafTags(paths:)`.

In order to render a view that contains Submissions leaf tags we need to ensure that the `Field`s are added to the field cache and that the `Request` is passed into the `render` call:

```swift
let nameField = Field(key: "name", value: "", label: "Name")
try req.fieldCache().addFields([nameField])
try req.view().render("index", on: req)
```

In your leaf file you can then refer to this field using an appropriate tag and the key "name" as defined when creating the Field.

### Tags

#### Input tags

The following input tags are available for your leaf files.

```
#submissions:checkbox( ... )
#submissions:email( ... )
#submissions:hidden( ... )
#submissions:password( ... )
#submissions:text( ... )
#submissions:textarea( ... )
```

They all accept the same number of parameters.

With these options:

Position | Type | Description | Example | Required?
-|-|-|-|-
1 | key | Key to the related field in the field cache | _"name"_ | yes
2 | placeholder | Placeholder text | _"Enter name"_ | no
3 | help text | Help text | _"This name will be visible to others"_ | no

#### File tag

To add a file upload to your form use this leaf tag.

```
#submissions:file( ... )
```

With these options:

Position | Type | Description | Example | Required?
-|-|-|-|-
1 | key | Key to the related field in the field cache | _"avatar"_ | yes
2 | help text | Help text | _"This will replace your existing avatar"_ | no
3 | accept | Placeholder text | _"image/*"_ | no
4 | multiple | Support multple file uploads | _"true"_ (or any other non-nil value) | no


#### Select tag

A select tag can be added as follows.

```
#submissions:select( ... )
```

With these options:

Position | Type | Description | Example | Required?
-|-|-|-|-
1 | key | Key to the related field in the field cache | _"role"_ | yes
2 | options | The possible options in the drop down | _roles_ | no
3 | placeholder | Placeholder text | _"Select an role"_ | no
4 | help text | Help text | _"The role defines the actions a user is allowed to perform"_ | no

The second option (e.g. `roles`) is a special parameter that defines the dropdown options. It has to be passed into the render call something like this.

```swift
enum Role: String, CaseIterable, Codable {
    case user, admin, superAdmin
}

extension Role: OptionRepresentable {
    var optionID: String? {
        return self.rawValue
    }

    var optionValue: String? {
        return self.rawValue.uppercased()
    }
}

let roles: [Role] = .
try req.view().render("index", ["roles": roles.allCases.makeOptions()] on: req)
```

## 🏆 Credits

This package is developed and maintained by the Vapor team at [Nodes](https://www.nodesagency.com).

## 📄 License

This package is open-sourced software licensed under the [MIT license](http://opensource.org/licenses/MIT).
