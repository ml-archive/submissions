import Validation

public struct Field: ValidationContextValidatable {
    public let label: String?
    public let value: String?
    private let _validate: (ValidationContext, Worker) throws -> Future<[ValidationError]>

    public init<T: LosslessStringConvertible>(
        label: String? = nil,
        value: T?,
        validators: [Validator<T>] = [],
        validate: @escaping (T?, ValidationContext, Worker) -> Future<[ValidationError]> = { _, _, worker in
            worker.future([])
        },
        isOptional: Bool = false,
        errorOnNil: ValidationError = BasicValidationError("Value may not be empty")
    ) {
        self.label = label
        self.value = value?.description
        _validate = { context, worker in
            let validationErrors: [ValidationError]

            switch (value, context, isOptional) {
            case (.none, .create, false):
                validationErrors = [errorOnNil]
            case (.some(let value), _, _):
                var errors: [ValidationError] = []
                for validator in validators {
                    do {
                        try validator.validate(value)
                    } catch let error as ValidationError {
                        errors.append(error)
                    }
                }
                validationErrors = errors
            default:
                validationErrors = []
            }

            return validate(value, context, worker).map { validationErrors + $0 }
        }
    }

    public func validate(
        inContext context: ValidationContext,
        on worker: Worker
    ) throws -> Future<[ValidationError]> {
        return try _validate(context, worker)
    }
}
