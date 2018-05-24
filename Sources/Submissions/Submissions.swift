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
