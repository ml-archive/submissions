import Validation
import Vapor

public struct Field {

    /// The key that references this field.
    let key: String

    /// A label describing this field. Used by Tags to render alongside an input field.
    let label: String?

    /// The value for this field represented as a `String`.
    let value: String?

    /// Whether or not values are allowed to be nil.
    let isRequired: Bool

    let validate: AsyncValidate

    /// Can validate asyncronously.
    public typealias AsyncValidate = (Request, ValidationContext) -> Future<[ValidationError]>

    init<T: CustomStringConvertible, V: SubmissionValidatable>(
        key: String,
        label: String?,
        value: T?,
        validatable: V?,
        validators: [Validator<T>],
        asyncValidators: [AsyncValidate],
        isRequired: Bool,
        requiredStrategy: RequiredStrategy,
        errorOnAbsense: ValidationError,
        absentValueStrategy: AbsentValueStrategy<T>
    ) {
        self.key = key
        self.label = label
        self.value = value?.description
        self.isRequired = isRequired

        validate = { req, context in
            let errors: [ValidationError]
            if let value = value.flatMap(absentValueStrategy.valueIfPresent) {
                do {
                    errors = try validators.compactMap { validator in
                        do {
                            try validator.validate(value)
                            return nil
                        } catch let error as ValidationError {
                            return error
                        }
                    }
                } catch {
                    return req.future(error: error)
                }
            } else if requiredStrategy.isRequired(context) {
                errors = [errorOnAbsense]
            } else {
                errors = []
            }

            return asyncValidators
                .map { validator in validator(req, context) }
                .flatten(on: req)
                .map {
                    $0.flatMap { $0 } + errors
                }
        }
    }
}
