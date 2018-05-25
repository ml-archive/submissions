import Vapor

public protocol SubmittableType: Decodable {
    associatedtype Submission: SubmissionType where Submission.Submittable == Self
    associatedtype Create: Decodable

    init(_: Create)
    mutating func update(_: Submission)
}
