//import Vapor

///// A field with a key.
//public struct FieldEntry<S: Submittable> {
//    var key: String
//    var field: Field<S>
//
//    /// Create a new `FieldEntry`.
//    /// - Parameters:
//    ///   - keyPath: Path to the value for the field.
//    ///   - field: A field.
//    /// - Throws: When determining the key from the key path fails.
//    init<A: Reflectable, B>(keyPath: KeyPath<A, B>, field: Field<S>) throws {
//        guard let paths = try A.reflectProperty(forKey: keyPath)?.path, paths.count > 0 else {
//            throw SubmissionError.invalidPathForKeyPath
//        }
//
//        key = paths.joined(separator: ".")
//        self.field = field
//    }
//}

//public struct FieldEntry {
//    var key: String
//    var field: Field
//
//    init<A: Reflectable, B>(keyPath: KeyPath<A, B>, field: Field) throws {
//        guard let paths = try A.reflectProperty(forKey: keyPath)?.path, paths.count > 0 else {
//            throw SubmissionError.invalidPathForKeyPath
//        }
//
//        key = paths.joined(separator: ".")
//        self.field = field
//    }
//}
