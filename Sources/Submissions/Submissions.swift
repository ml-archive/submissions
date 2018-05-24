import Sugar
import Vapor

public enum ValidationResult {
    case success
    case failure(SubmissionValidationError)
}

public protocol SubmissionType: Decodable {
    associatedtype Submittable: SubmittableType

    static var empty: Self { get }
    func makeFields() -> [String: Field]
    init(_ submittable: Submittable)
}

extension SubmissionType {
    public func validate(
        inContext context: ValidationContext,
        on worker: Worker
    ) throws -> Future<ValidationResult> {
        return try makeFields().validate(inContext: context, on: worker)
    }
}

public protocol SubmittableType: Decodable {
    associatedtype Submission: SubmissionType where Submission.Submittable == Self
    associatedtype Create: Decodable

    init(_: Create)
    mutating func update(_: Submission)
}

public enum ValidationContext {
    case create
    case update
}

extension Future where T: SubmissionType {
    public func validate(inContext context: ValidationContext, on worker: Worker) -> Future<T> {
        return flatMap { submission in
            try submission
                .validate(inContext: context, on: worker)
                .transform(to: submission)
        }
    }
}
