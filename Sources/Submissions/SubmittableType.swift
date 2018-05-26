import Sugar
import Vapor

public protocol SubmittableType: Decodable {
    associatedtype Submission: SubmissionType where Submission.Submittable == Self
    associatedtype Create: Decodable

    init(_: Create)
    mutating func update(_: Submission)
}

extension Future where T: SubmissionType {
    public func createValid(on req: Request) -> Future<T.Submittable> {
        return validate(inContext: .create, on: req)
            .flatMap { _ in
                try req.content.decode(T.Submittable.Create.self)
            }
            .map(T.Submittable.init)
    }
}

extension Future where T: SubmittableType {
    public func updateValid(on req: Request) -> Future<T> {
        return flatMap(to: T.self) { submittable in
            try req.content.decode(T.Submission.self)
                .validate(inContext: .update, on: req)
                .map { submission in
                    var mutableInstance = submittable
                    mutableInstance.update(submission)
                    return mutableInstance
            }
        }
    }

    public func populateFields(on req: Request) -> Future<T> {
        return self.try { submittable in
            try req.populateFields(with: T.Submission(submittable).makeFields())
        }
    }
}
