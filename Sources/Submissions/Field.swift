import Validation
import Vapor

/// Represents a property that can be rendered in an html form and validated on submission.
public struct Field {
    /// A label describing this field. Used by Tags to render alongside an input field.
    public let label: String?

    /// The value for this field represented as a `String`.
    public let value: String?

    /// Whether or not values are allowed to be nil
    public let isRequired: Bool

    private let _validate: (ValidationContext, Request) throws -> Future<[ValidationError]>

    /// A closure that can perform async validation of a value in a validation context on a worker.
    public typealias Validate<T> = (T?, ValidationContext, Request) throws -> Future<[ValidationError]>

    init<T: CustomStringConvertible>(
        label: String? = nil,
        value: T?,
        validators: [Validator<T>] = [],
        asyncValidators: [Validate<T>],
        isRequired: Bool = true,
        allowValues: [String] = [""],
        errorOnNil: ValidationError
    ) {
        self.label = label
        self.value = value?.description
        self.isRequired = isRequired
        _validate = { context, req in
            let validationErrors: [ValidationError]

            switch (value, context, isRequired) {
            case (.none, .create, true):
                validationErrors = [errorOnNil]
            case (.some(let value), _, _):
                var errors: [ValidationError] = []

                guard !allowValues.contains(value.description) else {
                    fallthrough
                }

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

            return try asyncValidators
                .map { validator in
                    try validator(value, context, req)
                }
                .flatten(on: req)
                .map { errors in
                    Array(errors.joined())
                }
                .map { validationErrors + $0 }
        }
    }

    /// Validate the `Field`'s value using provided validators.
    ///
    /// - Parameters:
    ///   - context: The context to respect when validating.
    ///   - worker: A `Worker` to perform the async validation on.
    /// - Returns: An array of `ValidationError`s in the `Future`.
    /// - Throws: Any non-validation related error
    public func validate(
        inContext context: ValidationContext,
        on req: Request
    ) throws -> Future<[ValidationError]> {
        return try _validate(context, req)
    }
}
