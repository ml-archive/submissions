import Validation

public struct SubmissionValidationError: Error {
    public let validationErrors: [String: [ValidationError]]
    init?(validationErrors: [String: [ValidationError]]) {
        if validationErrors.isEmpty {
            return nil
        } else {
            self.validationErrors = validationErrors
        }
    }
}
