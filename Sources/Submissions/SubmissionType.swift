import Vapor

/// A payload containing fields to use when creating or updating an entity.
public protocol SubmissionType: Decodable, Reflectable {
    associatedtype Submittable: SubmittableType

    /// An empty version of this type. Used for displaying labels when creating a new entity.
    static var empty: Self { get }

    /// The field entries (fields with associated keys).
    func fieldEntries() throws -> [FieldEntry]

    /// Create a submission value from a `Submittable`. Used when editing an entity to populate a
    /// form with its values
    ///
    /// - Parameter submittable: The value to read the properties from.
    init(_ submittable: Submittable)
}

extension SubmissionType {

    /// Make a field entry corresponding to a key path.
    ///
    /// - Parameters:
    ///   - label: A label describing this field.
    ///   - value: The value for this field.
    ///   - validators: The validators to use when validating the value.
    ///   - validate: A closure to perform any additional validation that requires async.
    ///   - isOptional: Whether or the value is allowed to be `nil`.
    ///   - errorOnNil: The error to be thrown in the `create` context for `nil` values when
    ///     `isOptional` is `false`.
    public func makeFieldEntry<T: CustomStringConvertible>(
        keyPath: KeyPath<Self, T>,
        label: String? = nil,
        validators: [Validator<T>] = [],
        validate: @escaping Field.Validate<T> = { _, _, worker in worker.future([]) },
        isOptional: Bool = false,
        errorOnNil: ValidationError = BasicValidationError.onNil
    ) throws -> FieldEntry {
        return try .init(
            keyPath: keyPath,
            field: Field(
                label: label,
                value: self[keyPath: keyPath],
                validators: validators,
                validate: validate,
                isOptional: isOptional,
                errorOnNil: errorOnNil
            )
        )
    }

    /// Make a field entry corresponding to a key path with an optional value.
    ///
    /// - Parameters:
    ///   - label: A label describing this field.
    ///   - value: The value for this field.
    ///   - validators: The validators to use when validating the value.
    ///   - validate: A closure to perform any additional validation that requires async.
    ///   - isOptional: Whether or the value is allowed to be `nil`.
    ///   - errorOnNil: The error to be thrown in the `create` context for `nil` values when
    ///     `isOptional` is `false`.
    public func makeFieldEntry<T: CustomStringConvertible>(
        keyPath: KeyPath<Self, T?>,
        label: String? = nil,
        validators: [Validator<T>] = [],
        validate: @escaping Field.Validate<T> = { _, _, worker in worker.future([]) },
        isOptional: Bool = false,
        errorOnNil: ValidationError = BasicValidationError.onNil
    ) throws -> FieldEntry {
        return try .init(
            keyPath: keyPath,
            field: Field(
                label: label,
                value: self[keyPath: keyPath],
                validators: validators,
                validate: validate,
                isOptional: isOptional,
                errorOnNil: errorOnNil
            )
        )
    }

    /// Trasnforms the field entries into a map of keys to fields.
    ///
    /// - Returns: The fields keyed by their corresponding paths
    /// - Throws: When creating the field entries fails.
    func makeFields() throws -> [String: Field] {
        return try Dictionary(fieldEntries().map { ($0.key, $0.field) }) { $1 }
    }

    /// Validates the fields with their current values using their validators.
    /// When a `SubmissionValidationError` occurs the container is populated with the underlying
    /// validation errors and the fields.
    ///
    /// - Parameters:
    ///   - context: The context (update/create) to respect when validating
    ///   - container: The container with the event loop to validate on and the field cache to store
    ///     any validation errors.
    /// - Returns: A `Future` of `Self`
    /// - Throws: any non-validation related errors that may occur.
    public func validate(
        inContext context: ValidationContext,
        on container: Container
    ) throws -> Future<Self> {
        let fields = try makeFields()

        return try fields
            .compactMap { key, value in
                try value
                    .validate(inContext: context, on: container)
                    .map { errors in
                        (key, errors)
                    }
            }
            .flatten(on: container)
            .map { errors in
                errors.filter { _, value in !value.isEmpty }
            }
            .map { errors in
                if let error = SubmissionValidationError(
                    fields: fields,
                    validationErrors: .init(uniqueKeysWithValues: errors)
                ) {
                    try container.populateFields(
                        with: error.fields,
                        andErrors: error.validationErrors
                    )
                    throw error
                }
                return self
            }
    }
}

extension BasicValidationError {

     /// The default error to throw when a value is empty when that is not valid.
     public static var onNil: BasicValidationError {
        return .init("Value may not be empty")
    }
}

extension Future where T: SubmissionType {
    
    /// Convenience for calling `validate` on submissions produced by this `Future`.
    ///
    /// - Parameters:
    ///   - context: The context (update/create) to respect when validating
    ///   - container: The container with the event loop to validate on and the field cache to store
    ///     any validation errors.
    /// - Returns: A `Future` of the `SubmissionType` value.
    public func validate(inContext context: ValidationContext, on container: Container) -> Future<T> {
        return flatMap { submission in
            try submission.validate(inContext: context, on: container)
        }
    }
}
