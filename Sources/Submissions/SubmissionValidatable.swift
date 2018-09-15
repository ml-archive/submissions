import Vapor

public protocol SubmissionValidatable {
    static func makeFields(for validatable: Self?) throws -> [Field]
}

extension SubmissionValidatable {
    public static func populateFieldCache(
        on req: Request,
        withValuesFrom instance: Self? = nil
    ) throws {
        let fieldCache = try req.fieldCache()
        let fields = try makeFields(for: instance)
        fields.forEach { field in
            let key = field.key
            fieldCache[valueFor: key] = field
            let errors = field.validate(req)
            fieldCache[errorsFor: key] = errors.map { $0.map { $0.reason } }
        }
    }

    public func populateFieldCache(on req: Request) throws {
        try Self.populateFieldCache(on: req, withValuesFrom: self)
    }

    public func validate(
        on req: Request
    ) throws -> Future<Either<Self, SubmissionValidationError>> {
        try populateFieldCache(on: req)
        let fieldCache = try req.fieldCache()
        return fieldCache
            .errors
            .values
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
    public static func key<T>(for keyPath: KeyPath<Self, T>) throws -> String {
        guard let paths = try Self.reflectProperty(forKey: keyPath)?.path, paths.count > 0 else {
            throw SubmissionError.invalidPathForKeyPath
        }

        return paths.joined(separator: ".")
    }
}

extension Optional where Wrapped: SubmissionValidatable & Reflectable {
    public func makeField<T: CustomStringConvertible>(
        keyPath: KeyPath<Wrapped, T>,
        label: String? = nil,
        validators: [Validator<T>] = [],
        asyncValidators: [Field.Validate] = [],
        isRequired: Bool = false,
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
            errorOnAbsense: errorOnAbsense,
            absentValueStrategy: absentValueStrategy
        )
    }

    public func makeField<T: CustomStringConvertible>(
        keyPath: KeyPath<Wrapped, T?>,
        label: String? = nil,
        validators: [Validator<T>] = [],
        asyncValidators: [Field.Validate] = [],
        isRequired: Bool = false,
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
            errorOnAbsense: errorOnAbsense,
            absentValueStrategy: absentValueStrategy
        )
    }
}
