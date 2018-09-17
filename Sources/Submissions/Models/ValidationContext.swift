/// Introduces a context to the validation process. It is used together with `RequiredStrategy` to
/// determine how treat missing values. In addition it is passed to the `AsyncValidate` closures
/// for custom
public enum ValidationContext: Equatable {
    
    /// Used when creating a new entity, eg. to render a blank form without validation errors
    case new

    /// Used for validating a new entity
    case create

    /// Used for validating an update to an existing entity
    case update

    /// A custom context
    case custom(String)
}
