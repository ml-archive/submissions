import Vapor

/// Defines the ability for a type to be submitted and validated with help of an associated type.
public protocol Submittable {

    typealias SubmissionType = Decodable & FieldsRepresentable & Reflectable

    /// A type representing the data to be validated.
    associatedtype Submission: SubmissionType

    /// Make fields for validation in addition to the ones from the `Submission` given an existing
    /// `Stubmittabl` entity. This can be used when the validation depends on an existing entity.
    /// For example to add a filter to a database query ensuring uniqueness of a property.
    ///
    /// - Parameters:
    ///   - submission: the submission containing new values, or nil.
    ///   - existing: an existing entity, or nil.
    /// - Returns: An array of `Field`s.
    static func makeAdditionalFields(
        for submission: Submission?,
        given existing: Self?
    ) throws -> [Field]

    func makeSubmission() -> Submission
}

extension Submittable {

    /// Make fields for a `Submittable`. Includes fields from the `Submission` and additional
    /// Fields.
    ///
    /// - Parameters:
    ///   - submission: the submission containing new values, or nil.
    ///   - existing: an existing entity, or nil.
    /// - Returns: An array of `Field`s.
    public static func makeFields(
        for submission: Submission? = nil,
        given existing: Self? = nil
    ) throws -> [Field] {
        return try Submission.makeFields(for: submission) +
            makeAdditionalFields(for: submission, given: existing)
    }
}

extension Submittable {

    /// See `Submittable`. Default implentation that returns an empty array.
    public static func makeAdditionalFields(
        for submission: Submission?,
        given existing: Self?
    ) throws -> [Field] {
        return []
    }
}
