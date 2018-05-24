import Validation

public protocol ValidationContextValidatable {
    func validate(
        inContext: ValidationContext,
        on worker: Worker
    ) throws -> Future<[ValidationError]>
}

extension Dictionary where Key == String, Value: ValidationContextValidatable {
    public func validate(
        inContext context: ValidationContext,
        on worker: Worker
    ) throws -> Future<ValidationResult> {
        return try compactMap { key, value in
            try value.validate(inContext: context, on: worker).map { errors in
                (key, errors)
            }
            }.flatten(on: worker)
            .map {
                if let error = SubmissionValidationError(
                    validationErrors: .init(uniqueKeysWithValues: $0)
                ) {
                    return .failure(error)
                } else {
                    return .success
                }
            }
    }
}
