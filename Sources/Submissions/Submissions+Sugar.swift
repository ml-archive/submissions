import Sugar
import Vapor

extension Submittable where Self: Creatable {

    /// See `Creatable`.
    public static func preCreate(on req: Request) -> Future<Void> {
        return Future.flatMap(on: req) {
            let fields = try Self.makeFields(for: req.content.syncDecode(Submission.self))
            return try req.fieldCache()
                .addFields(fields, on: req)
                .validate(inContext: .create, on: req)
                .assertValid(on: req)
        }
    }
}

extension Submittable where Self: Updatable {

    /// See `Updatable`.
    public func preUpdate(on req: Request) -> Future<Void> {
        return Future.flatMap(on: req) {
            let fields = try Self.makeFields(
                for: req.content.syncDecode(Submission.self),
                given: self
            )
            return try req.fieldCache()
                .addFields(fields, on: req)
                .validate(inContext: .update, on: req)
                .assertValid(on: req)
        }
    }
}

extension Loginnable where Self.Login: Submittable {

    /// See `Loginnable`.
    public static func preLogin(on req: Request) -> Future<Void> {
        return Future.flatMap(on: req) {
            let fields = try req.content.syncDecode(Login.Submission.self).makeFields()
            return try req.fieldCache()
                .addFields(fields, on: req)
                .validate(inContext: .create, on: req)
                .assertValid(on: req)
        }
    }
}
