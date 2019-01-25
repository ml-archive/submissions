import Vapor

public enum FileAbsentValueStrategy {
    /// Treat empty file object as absent.
    case `default`
}

extension FileAbsentValueStrategy: AbsentValueStrategy {

    public func valueIfPresent<T: CustomStringConvertible>(_ value: T?) -> T? {
        guard let file = value as? File else {
            return nil
        }
        return file.data.isEmpty ? nil : value
    }
}
