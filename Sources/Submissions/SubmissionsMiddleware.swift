import Vapor

/// Middleware that intercepts and `SubmissionValidationError`s and renders them as `Response`s.
///
/// Note: needs to come after `ErrorMiddleware` (if present) to avoid the
/// `SubmissionValidationError`s from being transformed into Internal Server errors on the way back
/// up the responder chain.
public final class SubmissionsMiddleware: Middleware, ServiceType {

	/// See `ServiceType`.
	public static func makeService(for container: Container) throws -> SubmissionsMiddleware {
		return SubmissionsMiddleware()
	}
	
    /// Create a new `SubmissionsMiddleware`.
    public init() {}

    /// See `Middleware`.
    public func respond(
        to req: Request,
        chainingTo next: Responder
    ) throws -> Future<Response> {
        return Future
            .flatMap(on: req) {
                try next.respond(to: req)
            }.catchFlatMap { error in
                if let error = error as? SubmissionValidationError {
                    return try error.encode(for: req)
                } else {
                    throw error
                }
            }
    }
}
