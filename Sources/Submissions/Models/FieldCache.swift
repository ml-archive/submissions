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
}

extension Request {

    /// Creates or retreives a field cache object.
    ///
    /// - Returns: The `FieldCache`
    /// - Throws: When no `FieldCache` has been registered with this container.
    public func fieldCache() throws -> FieldCache {
        return try privateContainer.make()
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
    ) -> FieldCache {
        fields.forEach { key, field in
            let existing = errors[key, default: req.future([])]
            let new = field.validate(req, context).map { $0.map { $0.reason } }

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
