import Vapor

public protocol SubmissionValidatable {
    static func makeFields(for validatable: Self?) throws -> [Field<Self>]
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
            fieldCache[valueFor: key] = AnyField(field)
            let errors = field.validate(req, instance)
            fieldCache[errorsFor: key] = errors.map { $0.map { $0.reason } }
        }
    }

    public func populateFieldCache(on req: Request) throws {
        try Self.populateFieldCache(on: req, withValuesFrom: self)
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
        asyncValidators: [Field<Wrapped>.Validate] = [],
        isRequired: Bool = false,
        errorOnAbsense: ValidationError = BasicValidationError("is absent"),
        absentValueStrategy: AbsentValueStrategy<T> = .nil
    ) throws -> Field<Wrapped> {
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
        asyncValidators: [Field<Wrapped>.Validate] = [],
        isRequired: Bool = false,
        errorOnAbsense: ValidationError = BasicValidationError("is absent"),
        absentValueStrategy: AbsentValueStrategy<T> = .nil
    ) throws -> Field<Wrapped> {
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
