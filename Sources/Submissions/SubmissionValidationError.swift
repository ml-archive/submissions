import Validation
import Vapor

public struct SubmissionValidationError: Error {
    public let fields: [String: Field]
    public let validationErrors: [String: [ValidationError]]
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
