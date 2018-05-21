import Sugar
import Vapor

// TODO: remove FieldsType and put it all on submittable?
public protocol FieldsType {
    associatedtype Submission: Decodable
    var fields: [String: FieldType] { get }
    init(_ submission: Submission)
    init()
}

extension FieldsType {
    func failedValidations(mode: ValidationMode) throws {
        let r: [String: [ValidationError]] = try Dictionary(
            uniqueKeysWithValues: fields.compactMap { key, value in
                let errors = try value.errors(mode)
                guard !errors.isEmpty else {
                    return nil
                }
                return (key, errors)
            }
        )
        if !r.isEmpty {
            throw SubmissionValidationError(failedValidations: r)
        }
    }
}

public protocol FieldsInitializable {
    associatedtype Fields: FieldsType
    init(_ fields: Fields)
}

public protocol Submittable: Decodable {
    associatedtype Fields
    associatedtype Update: FieldsInitializable where Update.Fields == Fields
    associatedtype Create: FieldsInitializable where Create.Fields == Fields

    init(_: Create)
    mutating func update(_: Update)
    func makeFields() -> Fields
}

extension ContentContainer {
    public func createValid<T: Submittable>(_ type: T.Type = T.self) throws -> Future<T> {
        return try decode(T.Fields.Submission.self)
            .map(T.Fields.init)
            .try {
                try $0.failedValidations(mode: .all)
            }
            .map(T.Create.init)
            .map(T.init)
    }

    public func updateValid<T: Submittable>(_ instance: T) throws -> Future<T> {
        return try decode(T.Fields.Submission.self)
            .map(T.Fields.init)
            .try {
                try $0.failedValidations(mode: .onlyNonNil)
            }
            .map(T.Update.init)
            .map { update in
                var mutatingInstance = instance
                mutatingInstance.update(update)
                return mutatingInstance
            }
    }
}

public enum ValidationMode {
    case none
    case onlyNonNil
    case all
}

public protocol FieldType {
    var label: String? { get }
    var stringValue: String? { get }
    func errors(_ mode: ValidationMode) throws -> [ValidationError]
}

public struct Field<V: LosslessStringConvertible>: FieldType {
    public let label: String?
    public let value: V?
    let validators: [Validator<V>]

    public var stringValue: String? {
        return value?.description
    }

    public init(
        label: String? = nil,
        value: V? = nil,
        validators: [Validator<V>] = []
    ) {
        self.label = label
        self.value = value
        self.validators = validators
    }

    public init(label: String? = nil, value: V? = nil, validator: Validator<V>) {
        self.init(label: label, value: value, validators: [validator])
    }

    public func errors(_ mode: ValidationMode) throws -> [ValidationError] {
        var errors: [ValidationError] = []

        if let value = value, mode != .none {
            for validator in validators {
                do {
                    try validator.validate(value)
                } catch let error as ValidationError {
                    errors.append(error)
                }
            }
        }

        return errors
    }
}
