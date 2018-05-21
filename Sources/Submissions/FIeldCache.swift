import Service

public final class FieldCache: Service {
    private var fields: [String: FieldType] = [:]
    private var errors: [String: [String]] = [:]
    public subscript(errorFor key: String) -> [String] {
        get {
            return errors[key] ?? []
        }
        set {
            errors[key] = newValue
        }
    }

    public subscript(valueFor key: String) -> FieldType? {
        get {
            return fields[key]
        }
        set {
            fields[key] = newValue
        }
    }

}

import Vapor

extension Request {
    public func fieldCache() throws -> FieldCache {
        return try make()
    }

    public func populateFields<S: Submittable>(from submittable: S.Type) throws {
        let fieldCache = try self.fieldCache()
        S.Fields().fields.forEach {
            fieldCache[valueFor: $0.key] = $0.value
        }
    }

    public func populateFields<S: Submittable>(from submittable: S) throws {
        let fieldCache = try self.fieldCache()
        submittable.makeFields().fields.forEach {
            fieldCache[valueFor: $0.key] = $0.value
        }
    }


//    func setField(_ field: String, to value: FieldType?) throws {
//        try fieldCache()[valueFor: field] = value
//    }
}
