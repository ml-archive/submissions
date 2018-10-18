import Validation
import Vapor

public struct Field {

    /// The key that references this field.
    let key: String

    /// A label describing this field. Used by Tags to render alongside an input field.
    let label: String?

    /// The value for this field represented as a `String`.
    let value: String?

    /// Whether or not values are allowed to be absent.
    let isRequired: Bool

    let validate: Validate

    /// Can validate asyncronously.
    public typealias Validate = (Request, ValidationContext) -> Future<[ValidationError]>

    public init<T: CustomStringConvertible>(
        key: String,
        label: String?,
        value: T?,
        validators: [Validator<T>],
        asyncValidators: [Validate],
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

extension Optional where Wrapped: Reflectable {

    /// Make a field corresponding to a key path.
    ///
    /// - Parameters:
    ///   - keyPath: Path to the value on the submission type.
    ///   - label: A label describing this field.
    ///   - validators: The validators to use when validating the value.
    ///   - asyncValidators: A closure to perform any additional validation that requires async.
    ///       Takes a request. See `Field.AsyncValidate`.
    ///   - isRequired: Whether or not the value is allowed to be absent.
    ///   - errorOnAbsense: The error to be thrown in the `create` context when value is absent as
    ///       determined by `absentValueStrategy` and `isRequired` is `true`.
    ///   - absentValueStrategy: Determines which (string) values to treat as absent.
    public func makeField<T: CustomStringConvertible>(
        keyPath: KeyPath<Wrapped, T>,
        label: String? = nil,
        validators: [Validator<T>] = [],
        asyncValidators: [Field.Validate] = [],
        isRequired: Bool = false,
        requiredStrategy: RequiredStrategy = .onCreateOrUpdate,
        errorOnAbsense: ValidationError = BasicValidationError("is absent"),
        absentValueStrategy: AbsentValueStrategy<T> = .nil
    ) throws -> Field {
        return try Field(
            key: Wrapped.key(for: keyPath),
            label: label,
            value: self?[keyPath: keyPath],
            validators: validators,
            asyncValidators: asyncValidators,
            isRequired: isRequired,
            requiredStrategy: requiredStrategy,
            errorOnAbsense: errorOnAbsense,
            absentValueStrategy: absentValueStrategy
        )
    }

    /// Make a field corresponding to a key path with an optional value.
    ///
    /// - Parameters:
    ///   - keyPath: Path to the value on the submission type.
    ///   - label: A label describing this field.
    ///   - validators: The validators to use when validating the value.
    ///   - asyncValidators: A closure to perform any additional validation that requires async.
    ///       Takes a request. See `Field.AsyncValidate`.
    ///   - isRequired: Whether or not the value is allowed to be absent.
    ///   - errorOnAbsense: The error to be thrown in the `create` context when value is absent as
    ///       determined by `absentValueStrategy` and `isRequired` is `true`.
    ///   - absentValueStrategy: Determines which (string) values to treat as absent.
    public func makeField<T: CustomStringConvertible>(
        keyPath: KeyPath<Wrapped, T?>,
        label: String? = nil,
        validators: [Validator<T>] = [],
        asyncValidators: [Field.Validate] = [],
        isRequired: Bool = false,
        requiredStrategy: RequiredStrategy = .onCreateOrUpdate,
        errorOnAbsense: ValidationError = BasicValidationError("is absent"),
        absentValueStrategy: AbsentValueStrategy<T> = .nil
    ) throws -> Field {
        return try Field(
            key: Wrapped.key(for: keyPath),
            label: label,
            value: self?[keyPath: keyPath],
            validators: validators,
            asyncValidators: asyncValidators,
            isRequired: isRequired,
            requiredStrategy: requiredStrategy,
            errorOnAbsense: errorOnAbsense,
            absentValueStrategy: absentValueStrategy
        )
    }
}

extension Reflectable {
    fileprivate static func key<T>(for keyPath: KeyPath<Self, T>) throws -> String {
        guard let paths = try Self.reflectProperty(forKey: keyPath)?.path, paths.count > 0 else {
            throw SubmissionError.invalidPathForKeyPath
        }

        return paths.joined(separator: ".")
    }
}
