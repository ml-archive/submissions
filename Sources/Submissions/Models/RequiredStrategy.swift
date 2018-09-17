/// A way to determine whether a field is required given a validation context
public struct RequiredStrategy {

    /// Determines whether a field is required given a validation context
    public typealias IsRequired = (ValidationContext) -> Bool

    let isRequired: IsRequired

    /// Creates a new `RequiredStrategy`.
    ///
    /// - Parameter isRequired: Determines whether a field is required given a validation context.
    public init(_ isRequired: @escaping IsRequired) {
        self.isRequired = isRequired
    }

    /// Field is always required.
    public static let always = RequiredStrategy { _ in true }

    /// Field is never required.
    public static let never = RequiredStrategy { _ in false }

    /// Field is required only when creating a new entity.
    public static let onCreate = RequiredStrategy { $0 == .create }

    /// Field is required only when updating an existing entity.
    public static let onUpdate = RequiredStrategy { $0 == .update }

    /// Field is required both when creating as well as when updating an entity.
    public static let onCreateOrUpdate = RequiredStrategy { $0 == .create || $0 == .update }
}
