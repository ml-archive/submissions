import Service
import Vapor

public final class FieldCache: Service {
    private var fields: [String: Field] = [:]
    private var errors: [String: [String]] = [:]
    public subscript(errorFor key: String) -> [String] {
        get {
            return errors[key] ?? []
        }
        set {
            errors[key] = newValue
        }
    }

    public subscript(valueFor key: String) -> Field? {
        get {
            return fields[key]
        }
        set {
            fields[key] = newValue
        }
    }
}

extension Container {
    public func fieldCache() throws -> FieldCache {
        return try make()
    }

    public func populateFields(
        with fields: [String: Field],
        andErrors errors: [String: [ValidationError]] = [:]
    ) throws {
        let fieldCache = try self.fieldCache()
        fields.forEach {
            fieldCache[valueFor: $0.key] = $0.value
        }
        errors.forEach {
            fieldCache[errorFor: $0.key] = $0.value.map { $0.reason }
        }
    }
}
