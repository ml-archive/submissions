import Validation

public enum ValidationContext {
    case create
    case update
}

public protocol ValidationContextValidatable {
    func validate(
        inContext: ValidationContext,
        on worker: Worker
    ) throws -> Future<[ValidationError]>
}
