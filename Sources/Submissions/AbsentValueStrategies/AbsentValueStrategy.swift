import Vapor

/// Determine which values count as an absent value besides `nil`.
public protocol AbsentValueStrategy {
    func valueIfPresent<T: CustomStringConvertible>(_ value: T?) -> T?
}
