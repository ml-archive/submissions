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

    /// Add any values and errors from fields to the `FieldCache` so they are available to the
    /// `InputTag`.
    ///
    /// - Parameters:
    ///   - fields: the fields containing the values and errors.
    ///   - context: the context in which the validation should take place.
    ///   - req: the request.
    /// - Returns: the field cache itself (for method chaining).
    @discardableResult
    public func populate<S: Sequence>(
        with fields: S,
        inContext context: ValidationContext,
        on req: Request
    ) -> FieldCache where S.Element == Field {
        fields.forEach { field in
            let key = field.key
            self[valueFor: key] = field
            let errors = field.validate(req, context)
            self[errorsFor: key] = errors.map { $0.map { $0.reason } }
        }
        return self
    }

    /// Validates the values in the field cache.
    ///
    /// Note: call `populate` at least once before calling this method.
    ///
    /// - Parameter req: the request
    /// - Returns: A `Future` that will indicate success or failure when the validation is finished.
    public func validate(on req: Request) -> Future<Void> {
        return errors.values
            .flatten(on: req)
            .map { $0.flatMap { $0 } }
            .map { errors in
                guard errors.isEmpty else {
                    throw SubmissionValidationError.invalid
                }
                return
            }
    }
}
