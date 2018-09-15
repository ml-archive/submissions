//import Validation
//import Vapor
//
///// An error signaling that Submission failed. All info about the error is stored in the FieldCache.
//public struct SubmissionValidationError: Error {}
//
//private struct ErrorResponse: Encodable {
//    /// Always set `error` to `true` in response.
//    let error = true
//
//    /// Reason for the error.
//    let reason = "One or more fields failed to pass validation."
//
//    /// Validation reason(s) per field.
//    let validationErrors: [String: [String]]
//}
//
//extension SubmissionValidationError: ResponseEncodable {
//    /// See `ResponseEncodable`
//    public func encode(for req: Request) throws -> Future<Response> {
//        let errorResponse = try ErrorResponse(validationErrors: req.fieldCache().errors)
//
//        let response = try req.makeResponse(
//            http: .init(
//                status: .unprocessableEntity,
//                body: HTTPBody(data: JSONEncoder().encode(errorResponse))
//            )
//        )
//        response.http.headers.replaceOrAdd(
//            name: .contentType,
//            value: "application/json; charset=utf8"
//        )
//
//        return req.future(response)
//    }
//}
