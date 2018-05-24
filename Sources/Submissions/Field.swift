import Validation

public struct Field: ValidationContextValidatable {
    public let label: String?
    public let value: String?
    // TODO: return Future<[ValidationError]>
    private let _validate: (ValidationContext) throws -> [ValidationError]

    // TODO: make variant with closure based validation (e.g. validate: [(T) throws -> Future<Void>])
    public init<T: LosslessStringConvertible>(
        label: String? = nil,
        value: T?,
        validators: [Validator<T>] = [],
        isOptional: Bool = false,
        errorOnNil: ValidationError = BasicValidationError("Value may not be empty")
        ) {
        self.label = label
        self.value = value?.description
        _validate = { context in
            switch (value, context, isOptional) {
            case (.none, .create, false):
                return [errorOnNil]
            case (.some(let value), _, _):
                var errors: [ValidationError] = []
                for validator in validators {
                    do {
                        try validator.validate(value)
                    } catch let error as ValidationError {
                        errors.append(error)
                    }
                }
                return errors
            default: return []
            }
        }
    }

    public func validate(inContext context: ValidationContext) throws -> [ValidationError] {
        return try _validate(context)
    }
}
