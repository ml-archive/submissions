/// Determine which values count as an absent value besides `nil`.
/// This can be useful to when dealing with empty strings or "null".
public enum AbsentValueStrategy<T> {
    /// Only treat `nil` as absent.
    case `nil`

    /// Defines a custom strategy to determine whether a value means it's absent
    case custom((T) -> Bool)
}

extension AbsentValueStrategy where T: Equatable {
    public static func equal(to reference: T) -> AbsentValueStrategy {
        return .custom {  $0 == reference }
    }

    public static func `in`(to reference: [T]) -> AbsentValueStrategy {
        return .custom { reference.contains($0) }
    }
}

extension AbsentValueStrategy {
    func valueIfPresent(_ value: T?) -> T? {
        switch (self, value) {
        case (.nil, _):
            return value
        case (.custom(let isAbsent), .some(let value)) where !isAbsent(value):
            return value
        default:
            return nil
        }
    }
}
