import Validation

public protocol ValidationContextValidatable {
    func validate(inContext: ValidationContext) throws -> [ValidationError]
}

extension Dictionary where Key == String, Value: ValidationContextValidatable {
    public func validate(inContext context: ValidationContext) throws -> ValidationResult {
        let r = try Dictionary<String, [ValidationError]>(
            uniqueKeysWithValues: compactMap { key, value in
                let errors = try value.validate(inContext: context)
                guard !errors.isEmpty else {
                    return nil
                }
                return (key, errors)
            }
        )
        if let error = SubmissionValidationError(validationErrors: r) {
            return .failure(error)
        }
        return .success
    }
}
