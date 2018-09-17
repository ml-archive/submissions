import Vapor

/// Types conforming to this protocol can be validated.
public protocol SubmissionValidatable {

    /// Implement this method to configure how this type should be validated.
    ///
    /// - Parameter validatable: the existing value (e.g. from the database), if any.
    /// - Returns: the `Field`s representing the validations to perform.
    static func makeFields(for validatable: Self?) throws -> [Field]
}

extension SubmissionValidatable {

    /// Add fields and errors (if any) to the `FieldCache` so they are available to the `InputTag`.
    ///
    /// - Parameters:
    ///   - req: the request
    ///   - context: the context in which the validation should take place.
    ///   - existingValidatable: the existing validatable value, if any.
    /// - Throws: if the `FieldCache` cannot be created or if `makeFields` throws an error.
    public static func populateFieldCache(
        on req: Request,
        inContext context: ValidationContext,
        withValuesFrom existingValidatable: Self? = nil
    ) throws {
        let fieldCache = try req.fieldCache()
        let fields = try makeFields(for: existingValidatable)
        fields.forEach { field in
            let key = field.key
            fieldCache[valueFor: key] = field
            let errors = field.validate(req, context)
            fieldCache[errorsFor: key] = errors.map { $0.map { $0.reason } }
        }
    }

    /// Add fields and errors (if any) to the `FieldCache` so they are available to the `InputTag`.
    ///
    /// - Parameters:
    ///   - req: the request
    ///   - context: the context in which the validation should take place.
    /// - Throws: if the `FieldCache` cannot be created or if `makeFields` throws an error.
    public func populateFieldCache(
        on req: Request,
        inContext context: ValidationContext
    ) throws {
        try Self.populateFieldCache(on: req, inContext: context, withValuesFrom: self)
    }

    /// Validates the validatable value. This also calls `populateFieldCache`.
    ///
    /// - Parameters:
    ///   - req: the request
    ///   - context: the context in which the validation should take place.
    /// - Returns: A `Future` of `Either` the valid validatable value or a
    ///     `SubmissionValidationError`
    /// - Throws: if the `FieldCache` cannot be created or if `makeFields` throws an error.
    public func validate(
        on req: Request,
        inContext context: ValidationContext
    ) throws -> Future<Either<Self, SubmissionValidationError>> {
        try populateFieldCache(on: req, inContext: context)
        let fieldCache = try req.fieldCache()
        return fieldCache.errors.values
            .flatten(on: req)
            .map { $0.flatMap { $0 } }
            .map { errors in
                if errors.isEmpty {
                    return .left(self)
                } else {
                    return .right(SubmissionValidationError.invalid)
                }
            }
    }
}

extension SubmissionValidatable where Self: Reflectable {
    static func key<T>(for keyPath: KeyPath<Self, T>) throws -> String {
        guard let paths = try Self.reflectProperty(forKey: keyPath)?.path, paths.count > 0 else {
            throw SubmissionError.invalidPathForKeyPath
        }

        return paths.joined(separator: ".")
    }
}

extension Optional where Wrapped: SubmissionValidatable & Reflectable {

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
        asyncValidators: [Field.AsyncValidate] = [],
        isRequired: Bool = false,
        requiredStrategy: RequiredStrategy = .onCreateOrUpdate,
        errorOnAbsense: ValidationError = BasicValidationError("is absent"),
        absentValueStrategy: AbsentValueStrategy<T> = .nil
    ) throws -> Field {
        return try Field(
            key: Wrapped.key(for: keyPath),
            label: label,
            value: self?[keyPath: keyPath],
            validatable: self,
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
        asyncValidators: [Field.AsyncValidate] = [],
        isRequired: Bool = false,
        requiredStrategy: RequiredStrategy = .onCreateOrUpdate,
        errorOnAbsense: ValidationError = BasicValidationError("is absent"),
        absentValueStrategy: AbsentValueStrategy<T> = .nil
    ) throws -> Field {
        return try Field(
            key: Wrapped.key(for: keyPath),
            label: label,
            value: self?[keyPath: keyPath],
            validatable: self,
            validators: validators,
            asyncValidators: asyncValidators,
            isRequired: isRequired,
            requiredStrategy: requiredStrategy,
            errorOnAbsense: errorOnAbsense,
            absentValueStrategy: absentValueStrategy
        )
    }
}
