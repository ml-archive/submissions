/// A type-erased version of `Field`
public struct AnyField {
    var label: String?
    var value: String?
    var isRequired: Bool

    init<S: Submittable>(_ field: Field<S>) {
        self.label = field.label
        self.value = field.value
        self.isRequired = field.isRequired
    }
}
