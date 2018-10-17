# Submissions 📩
[![Swift Version](https://img.shields.io/badge/Swift-4.2-brightgreen.svg)](http://swift.org)
[![Vapor Version](https://img.shields.io/badge/Vapor-3.1-30B6FC.svg)](http://vapor.codes)
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
    .package(url: "https://github.com/nodes-vapor/submissions.git", from: "2.0.0-beta")
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

## Defining your submitted data

### Validating API requests

## Validating HTML form requests

### Leaf tags

### Rendering the forms

### Validating and storing the data

## 🏆 Credits

This package is developed and maintained by the Vapor team at [Nodes](https://www.nodesagency.com).
The package owner for this project is [Siemen](https://github.com/siemensikkema).

## 📄 License

This package is open-sourced software licensed under the [MIT license](http://opensource.org/licenses/MIT).
