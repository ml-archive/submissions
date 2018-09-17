import Vapor

/// An error signaling that Submission failed. All info about the error is stored in the FieldCache.
public enum SubmissionValidationError: Error, Equatable {
    case invalid
}

private struct ErrorResponse: Encodable {

    /// Always set `error` to `true` in response.
    let error = true

    /// Reason for the error.
    let reason = "One or more fields failed to pass validation."

    /// Validation reason(s) per field.
    let validationErrors: [String: [String]]
}

extension SubmissionValidationError: ResponseEncodable {

    /// See `ResponseEncodable`.
    public func encode(for req: Request) throws -> Future<Response> {
        return try req.fieldCache().errors
            .compactMap { key, errors in
                errors.map {
                    (key, $0)
                }
            }
            .flatten(on: req)
            .flatMap { keyErrorsPairs in
                let validationErrors = Dictionary(keyErrorsPairs, uniquingKeysWith: { a, _ in a })
                    .filter { !$0.value.isEmpty }

                let errorResponse = ErrorResponse(validationErrors: validationErrors)
                let response = try req.makeResponse(
                    http: .init(
                        status: .unprocessableEntity,
                        body: HTTPBody(data: JSONEncoder().encode(errorResponse))
                    )
                )
                response.http.headers.replaceOrAdd(
                    name: .contentType,
                    value: "application/json; charset=utf8"
                )
                return req.future(response)
            }
    }
}
