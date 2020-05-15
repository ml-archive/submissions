import Service
import Vapor

/// A `FieldCache` contains the data used by `Tag`s to produce the fields in HTML forms.
public final class FieldCache: Service {
    var fields: [String: Field] = [:]
    var errors: [String: Future<[String]>] = [:]
}

extension FieldCache {

    /// Returns the errors for a field.
    ///
    /// - Parameter key: The identifier of the field.
    public subscript(errorsFor key: String) -> Future<[String]>? {
        get {
            return errors[key]
        }
        set {
            errors[key] = newValue
        }
    }

    /// Returns the value for a field.
    ///
    /// - Parameter key: The identifier of the field.
    public subscript(valueFor key: String) -> Field? {
        get {
            return fields[key]
        }
        set {
            fields[key] = newValue
        }
    }

    /// Returns the errors for all fields.
    public func getAllErrors(on worker: Worker) -> EventLoopFuture<[String: [String]]> {
        return errors.map { key, errorsFuture in
            errorsFuture.map { errors in (key, errors) }
        }
        .flatten(on: worker)
        .map(Dictionary.init(uniqueKeysWithValues:)) // safe to use because we know keys will be unique
    }
}

extension Request {

    /// Creates or retrieves a field cache object.
    ///
    /// - Returns: The `FieldCache`.
    /// - Throws: When no `FieldCache` has been registered with this container.
    public func fieldCache() throws -> FieldCache {
        return try privateContainer.make()
    }

    /// Add fields to the field cache.
    ///
    /// - Parameters:
    ///   - submission: The submission containing the values for the fields, or nil.
    ///   - submittable: An existing submittable value used during validation, or nil.
    ///   - type: The type of the Submittable. Only needed when `submission` == nil.
    /// - Returns: The `FieldCache`.
    /// - Throws: When no `FieldCache` has been registered with this container.
    @discardableResult
    public func addFields<S: Submittable>(
        for submission: S.Submission? = nil,
        given submittable: S? = nil,
        forType type: S.Type = S.self
    ) throws -> FieldCache {
        return try fieldCache()
            .addFields(S.makeFields(for: submission, given: submittable), on: self)
    }

    /// Add fields to the field cache.
    ///
    /// - Parameters:
    ///   - instance: The source of the values for the fields, or nil.
    ///   - type: The concrete type of the `FieldsRepresentable`.
    ///       Only needed when `submission` == nil.
    /// - Returns: The `FieldCache`.
    /// - Throws: When no `FieldCache` has been registered with this container.
    @discardableResult
    public func addFields<F: FieldsRepresentable>(
        for instance: F? = nil,
        forType type: F.Type = F.self
    ) throws -> FieldCache {
        return try fieldCache().addFields(F.makeFields(for: instance), on: self)
    }
}

extension Future where T: Submittable {

    /// Add fields to the field cache.
    ///
    /// - Parameters:
    ///   - req: The request.
    /// - Returns: A `Future` of `T`.
    public func addFields(on req: Request) -> Future<T> {
        return self.try { element in
            try req.addFields(given: element)
        }
    }
}

extension FieldCache {

    /// Add fields to the `FieldCache`.
    ///
    /// - Parameters:
    ///   - fields: the fields to add.
    ///   - req: the request.
    /// - Returns: the field cache itself (for method chaining).
    @discardableResult
    public func addFields<S: Sequence>(
        _ fields: S,
        on req: Request
    ) -> FieldCache where S.Element == Field {
        fields.forEach { field in
            let key = field.key
            self[valueFor: key] = field
        }
        return self
    }

    /// Validates the values in the field cache.
    ///
    /// Note: call `populate` before calling this method so there are fields to validate.
    ///
    /// - Parameters:
    ///   - req: the request.
    ///   - context: the context in which the validation should take place.
    /// - Returns: the field cache itself (for method chaining).
    @discardableResult
    public func validate(
        inContext context: ValidationContext,
        on req: Request
    ) throws -> FieldCache {
        try fields.forEach { key, field in
            let existing = errors[key, default: req.future([])]
            let new = try field.validate(req, context).map { $0.map { $0.reason } }

            errors[key] = existing.and(new).map(+)
        }
        return self
    }

    /// Inspects the `FieldCache` for errors.
    ///
    /// Note: call `populate` before calling this method so there are fields to validate.
    ///
    /// - Parameter req: the request.
    /// - Returns: A `Future` that will indicate success or failure when the validation is finished.
    public func assertValid(on req: Request) -> Future<Void> {
        return errors.values
            .flatten(on: req)
            .map { $0.flatMap { $0 } }
            .map { errors in
                guard errors.isEmpty else {
                    throw SubmissionValidationError()
                }
            }
    }
}
