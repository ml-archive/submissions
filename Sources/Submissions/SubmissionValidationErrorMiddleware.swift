import Vapor

/// Middleware that catches `SubmissionValidationError`s and pres
public final class SubmissionValidationErrorMiddleware: Service {
    private let environment: Environment
    private let log: Logger

    /// Create a `SubmissionValidationErrorMiddleware`.
    ///
    /// - Parameters:
    ///   - environment: The environment to respect when logging errors.
    ///   - log: Log destination
    public init(environment: Environment, log: Logger) {
        self.environment = environment
        self.log = log
    }

    private struct ErrorResponse: Encodable {
        /// Always set `error` to `true` in response.
        let error = true

        /// Reason for the error.
        let reason = "One or more fields failed to pass validation."

        /// Validation reason(s) per field.
        let validationErrors: [String: [String]]
    }

    private func handleValidationError(
        _ error: SubmissionValidationError,
        request: Request
    ) throws -> Response {
        log.report(error: error, verbose: !environment.isRelease)

        let validationErrors = error
            .validationErrors
            .mapValues { validationErrors in
                validationErrors.map { $0.reason }
        }
        let errorResponse = ErrorResponse(validationErrors: validationErrors)

        let response = try request.makeResponse(
            http: .init(
                status: .unprocessableEntity,
                body: HTTPBody(data: JSONEncoder().encode(errorResponse))
            )
        )
        response.http.headers.replaceOrAdd(
            name: .contentType,
            value: "application/json; charset=utf8"
        )
        return response
    }
}

extension SubmissionValidationErrorMiddleware: Middleware {

    /// See `Middleware`.
    public func respond(
        to request: Request,
        chainingTo next: Responder
    ) throws -> Future<Response> {
        return try next
            .respond(to: request)
            .catchMap { error in
                guard let validationError = error as? SubmissionValidationError else {
                    throw error
                }
                return try self.handleValidationError(validationError, request: request)
        }
    }
}
