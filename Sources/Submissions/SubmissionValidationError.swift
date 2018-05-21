import Validation

public struct SubmissionValidationError: Error {
    let failedValidations: [String: [ValidationError]]
}
