import Core
import Submissions
import Validation

struct User: Decodable, Reflectable {
    let name: String
    let requiredButOptional: Int?
    let emptyStringMeansAbsent: String
    let unique: String

    init(
        name: String = "",
        optional: Int? = nil,
        emptyStringMeansAbsent: String = "",
        unique: String = "unique"
    ) {
        self.name = name
        self.requiredButOptional = optional
        self.emptyStringMeansAbsent = emptyStringMeansAbsent
        self.unique = unique
    }
}

extension User: SubmissionValidatable {
    static func makeFields(for validatable: User?) throws -> [Field] {
        return try [
            validatable.makeField(
                keyPath: \.name,
                label: "Name",
                validators: [.count(2...)]
            ),
            validatable.makeField(
                keyPath: \.requiredButOptional,
                isRequired: true
            ),
            validatable.makeField(
                keyPath: \.emptyStringMeansAbsent,
                isRequired: true,
                absentValueStrategy: .equal(to: "")
            ),
            validatable.makeField(
                keyPath: \.unique,
                asyncValidators: [{ req in
                    req.future([BasicValidationError("must be unique")])
                }]
            )
        ]
    }
}
