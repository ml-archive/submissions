import Submissions
import Validation

extension Todo: Submittable {
    struct Fields: FieldsType {
        let titleField: Field<String>

        var fields: [String: FieldType] {
            return ["title": titleField]
        }

        init() {
            self.init(title: nil)
        }

        init(_ submission: Update) {
            self.init(title: submission.title)
        }

        init(title: String?) {
            titleField = Field(
                label: "Title",
                value: title,
                validator: Validator.count(5...)
            )
        }
    }

    struct Create: FieldsInitializable {
        let title: String
        init(_ fields: Fields) {
            // TODO: make some nice convenience for throwing error when values are nil
            title = fields.titleField.value!
        }
    }

    struct Update: Decodable, FieldsInitializable {
        let title: String?
        init(_ fields: Fields) {
            title = fields.titleField.value
        }
    }

    convenience init(_ create: Create) {
        self.init(id: nil, title: create.title)
    }

    func update(_ update: Update) {
        if let title = update.title {
            self.title = title
        }
    }

    func makeFields() -> Fields {
        return Fields(title: title)
    }
}
