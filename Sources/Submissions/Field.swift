import Validation
import Vapor

/// Represents a property that can be rendered in an html form and validated on submission.
public struct Field<S: Submittable> {
    /// A label describing this field. Used by Tags to render alongside an input field.
    public let label: String?

    /// The value for this field represented as a `String`.
    public let value: String?

    /// Whether or not values are allowed to be nil
    public let isRequired: Bool

    private let _validate: (ValidationContext, S?, Request) throws -> Future<[ValidationError]>

    /// A closure that can perform async validation of a value in a validation context on a worker.
    public typealias Validate<T> = (T?, ValidationContext, S?, Request) throws -> Future<[ValidationError]>

    init<T: CustomStringConvertible>(
        label: String? = nil,
        value: T?,
        validators: [Validator<T>] = [],
        asyncValidators: [Validate<T>],
        isRequired: Bool = true,
        absentValueStrategy: AbsentValueStrategy = .equal(""),
        errorOnAbsense: ValidationError
    ) {
        self.label = label
        self.value = value?.description
        self.isRequired = isRequired
        _validate = { context, submittable, req in
            let validationErrors: [ValidationError]

            switch (absentValueStrategy.valueIfPresent(value), context, isRequired) {
            case (.none, .create, true):
                validationErrors = [errorOnAbsense]
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

            return try asyncValidators
                .map { validator in
                    try validator(value, context, submittable, req)
                }
                .flatten(on: req)
                .map { asyncValidationErrors in
                    validationErrors + Array(asyncValidationErrors.joined())
                }
        }
    }

    /// Validate the `Field`'s value using provided validators.
    ///
    /// - Parameters:
    ///   - context: The context to respect when validating.
    ///   - submittable: An optional existing related submittable for reference when validating.
    ///   - req: A `Request` to perform the async validation on.
    /// - Returns: An array of `ValidationError`s in the `Future`.
    /// - Throws: Any non-validation related error
    public func validate(
        inContext context: ValidationContext,
        with submittable: S? = nil,
        on req: Request
    ) throws -> Future<[ValidationError]> {
        return try _validate(context, submittable, req)
    }
}
