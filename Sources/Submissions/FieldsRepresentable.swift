import Vapor

/// Types conforming can be represented as a list of fields.
public protocol FieldsRepresentable {

    /// Make an array of `Field`s for an optional instance.
    ///
    /// - Parameter instance: the instance of the `FieldsRepresentable` to make fields for.
    /// - Returns: an array of `Field`s.
    static func makeFields(for instance: Self?) throws -> [Field]
}

extension FieldsRepresentable {

    /// Make an array of `Field`s for a type (no instance).
    ///
    /// - Returns: an array of `Field`s.
    public static func makeFields() throws -> [Field] {
        return try makeFields(for: nil)
    }

    /// Make an array of `Field`s for the instance.
    ///
    /// - Returns: an array of `Field`s.
    public func makeFields() throws -> [Field] {
        return try Self.makeFields(for: self)
    }
}
