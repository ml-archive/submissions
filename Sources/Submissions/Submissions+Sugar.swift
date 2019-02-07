import Sugar
import Vapor

extension Submittable where Self: Creatable {

    /// See `Creatable`.
    public static func preCreate(on req: Request) -> Future<Void> {
        return .flatMap(on: req) {
            try req.content.decode(Submission.self)
                .flatMap { (submission: Submission) in
                    try req
                        .addFields(for: submission)
                        .validate(inContext: .create, on: req)
                        .assertValid(on: req)
                }
        }
    }
}

extension Submittable where Self: Updatable, Self.Update == Self.Submission {

    /// See `Updatable`.
    public func preUpdate(on req: Request) -> Future<Void> {
        return .flatMap(on: req) {
            try req.content.decode(Submission.self)
                .flatMap { (submission: Submission) in
                    try req
                        .addFields(for: submission, given: self)
                        .validate(inContext: .update, on: req)
                        .assertValid(on: req)
                }
        }
    }
}

extension Loginable where Self.Login: Submittable {

    /// See `Loginable`.
    public static func preLogin(on req: Request) -> Future<Void> {
        return .flatMap(on: req) {
            try req.content.decode(Login.Submission.self)
                .flatMap { (submission: Login.Submission) in
                    try req
                        .addFields(for: submission)
                        .validate(inContext: .create, on: req)
                        .assertValid(on: req)
            }
        }
    }
}
