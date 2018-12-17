import Vapor

public protocol Submittable {
    associatedtype Submission: Decodable, FieldsRepresentable, Reflectable

    static func makeAdditionalFields(
        for submission: Submission?,
        given existing: Self?
    ) throws -> [Field]

    func makeSubmission() -> Submission
}

extension Submittable {
    func makeFields(
        for submission: Submission? = nil
    ) throws -> [Field] {
        return try Self.makeFields(for: submission, given: self)
    }

    public static func makeFields(
        for submission: Submission? = nil,
        given existing: Self? = nil
    ) throws -> [Field] {
        return try submission?.makeFields() ?? [] +
            makeAdditionalFields(for: submission, given: existing)
    }
}

extension Submittable {
    public static func makeAdditionalFields(
        for submission: Submission?,
        given existing: Self?
    ) throws -> [Field] {
        return []
    }
}

extension Submittable {
    public func validate(inContext context: ValidationContext, on req: Request) throws {
        try req
            .fieldCache()
            .addFields(makeFields(for: req.content.syncDecode(Submission.self)), on: req)
            .validate(inContext: .update, on: req)
    }
}
