import Vapor

/// Determine which values count as an absent value besides `nil`.
/// This can be useful to when dealing with empty strings or "null".
public enum DefaultAbsentValueStrategy {
    /// Only treat `nil` as absent.
    case `nil`

    /// Treat value as absent when its description is equal to string.
    case equal(String)

    /// Treat value as absent when its description is equal to one of the strings.
    case `in`([String])
}

extension DefaultAbsentValueStrategy: AbsentValueStrategy {
    public func valueIfPresent<T: CustomStringConvertible>(_ value: T?) -> T? {
        switch (self, value) {
        case (.nil, _):
            return value
        case (.equal(let other), .some(let value)) where value.description != other:
            return value
        case (.in(let others), .some(let value)) where !others.contains(value.description):
            return value
        default:
            return nil
        }
    }
}
