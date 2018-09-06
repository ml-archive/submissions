import Service
import Vapor

/// A `FieldCache` contains the data used by `Tag`s to produce the fields in html forms.
public final class FieldCache: Service {
    var fields: [String: AnyField] = [:]
    var errors: [String: [String]] = [:]
}

extension FieldCache {
    /// Returns the errors for a field.
    ///
    /// - Parameter key: The identifier of the field.
    public subscript(errorsFor key: String) -> [String] {
        get {
            return errors[key] ?? []
        }
        set {
            errors[key] = newValue
        }
    }

    /// Returns the value for a field.
    ///
    /// - Parameter key: The identifier of the field.
    public subscript(valueFor key: String) -> AnyField? {
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

    /// Sets any fields on the field cache of this `Container` for the provided submittable.
    ///
    /// - Parameter submittable: an optional submittable value containing the values to set.
    /// - Throws: When no `FieldCache` has been registered with this container.
    public func populateFields<T: Submittable>(_ submittable: T?) throws {
        try _populateFields(submittable)
    }

    /// Sets any fields on the field cache of this `Container` for an empty `Submittable`.
    ///
    /// - Parameter _: The type for which to create the fields.
    /// - Throws: When no `FieldCache` has been registered with this container.
    public func populateFields<T: Submittable>(_: T.Type) throws {
        try _populateFields(Optional<T>.none)
    }

    private func _populateFields<T: Submittable>(_ submittable: T?) throws {
        try populateFields(with: T.Submission(submittable).makeFields().mapValues(AnyField.init))
    }

    /// Sets any fields and errors on the field cache of this `Container`.
    ///
    /// - Parameters:
    ///   - fields: `Field`s keyed by a name.
    ///   - errors: Arrays of `ValidationError`s per field name.
    /// - Throws: When no `FieldCache` has been registered with this container.
    public func populateFields(
        with fields: [String: AnyField],
        andErrors errors: [String: [ValidationError]] = [:]
    ) throws {
        let fieldCache = try self.fieldCache()
        fields.forEach {
            fieldCache[valueFor: $0.key] = $0.value
        }
        errors.forEach {
            fieldCache[errorsFor: $0.key] = $0.value.map { $0.reason }
        }
    }
}
