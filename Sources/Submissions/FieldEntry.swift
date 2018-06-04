import Vapor

/// A field with a key
public struct FieldEntry {
    var key: String
    var field: Field

    /// Create a new `FieldEntry`.
    /// - Parameters:
    ///   - keyPath:
    ///   - field: A field.
    /// - Throws: When determining the key from the key path fails
    init<A: Reflectable, B>(keyPath: KeyPath<A, B>, field: Field) throws {
        guard let paths = try A.reflectProperty(forKey: keyPath)?.path, paths.count > 0 else {
            throw SubmissionError.invalidPathForKeyPath
        }

        key = paths.joined(separator: ".")
        self.field = field
    }
}

enum SubmissionError: Error {
    case invalidPathForKeyPath
}

extension SubmissionError: AbortError {
    var identifier: String {
        return "invalidPathForKeyPath"
    }

    var reason: String {
        return "Invalid Path for KeyPath"
    }

    var status: HTTPResponseStatus {
        return .internalServerError
    }
}
