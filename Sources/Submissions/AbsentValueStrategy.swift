/// Determine which values count as an absent value besides `nil`.
/// This can be useful when dealing with empty strings or "null" for example.
public enum AbsentValueStrategy<T> {

    /// Only treat `nil` as absent.
    case `nil`

    /// Defines a custom strategy to determine whether a value means it's absent
    case custom((T) -> Bool)
}

extension AbsentValueStrategy where T: Equatable {

    /// Treat values as absent if they are equal to the provided value.
    ///
    /// - Parameter reference: reference value to compare to.
    /// - Returns: an `AbsentValueStrategy`
    public static func equal(to reference: T) -> AbsentValueStrategy {
        return .custom {  $0 == reference }
    }

    /// Treat values as absent if they are contained in the provided value.
    ///
    /// - Parameter reference: reference values to compare to.
    /// - Returns: an `AbsentValueStrategy`
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
