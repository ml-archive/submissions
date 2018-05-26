import Vapor

public protocol SubmissionType: Decodable {
    associatedtype Submittable: SubmittableType

    static var empty: Self { get }
    func makeFields() -> [String: Field]
    init(_ submittable: Submittable)
}

extension SubmissionType {
    public func validate(
        inContext context: ValidationContext,
        on container: Container
    ) throws -> Future<Self> {
        let fields = makeFields()

        return try fields
            .compactMap { key, value in
                try value
                    .validate(inContext: context, on: container)
                    .map { errors in
                        (key, errors)
                    }
            }
            .flatten(on: container)
            .map { errors in
                errors.filter { _, value in !value.isEmpty }
            }
            .map { errors in
                if let error = SubmissionValidationError(
                    fields: fields,
                    validationErrors: .init(uniqueKeysWithValues: errors)
                ) {
                    try container.populateFields(
                        with: error.fields,
                        andErrors: error.validationErrors
                    )
                    throw error
                }
                return self
            }
    }
}

extension Future where T: SubmissionType {
    public func validate(inContext context: ValidationContext, on container: Container) -> Future<T> {
        return flatMap { submission in
            try submission.validate(inContext: context, on: container)
        }
    }
}
