import Validation
import Vapor

/// An error containing fields and failed validations of a submission payload.
public struct SubmissionValidationError: Error {

    /// All fields of the submission payload.
    public let fields: [String: Field]

    /// The underlying validation errors.
    public let validationErrors: [String: [ValidationError]]

    /// Create a new `SubmissionValidationError`.when any validation errors exist.
    ///
    /// - Parameters:
    ///   - fields: All fields of the submission payload.
    ///   - validationErrors: The underlying validation errors.
    init?(fields: [String: Field], validationErrors: [String: [ValidationError]]) {
        self.fields = fields
        if validationErrors.isEmpty {
            return nil
        } else {
            self.validationErrors = validationErrors
        }
    }
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

    /// See `ResponseEncodable`
    public func encode(for req: Request) throws -> Future<Response> {
        let validationErrors = self
            .validationErrors
            .mapValues { validationErrors in
                validationErrors.map { $0.reason }
            }
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
