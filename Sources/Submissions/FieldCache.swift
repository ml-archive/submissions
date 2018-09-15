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
