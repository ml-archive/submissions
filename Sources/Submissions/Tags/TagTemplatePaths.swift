/// Configuration for template paths used when rendering tags.
public struct TagTemplatePaths {

    /// Path to template for input element of type "checkbox"
    public let checkboxField: String

    /// Path to template for input element of type "email"
    public let emailField: String

    /// Path to template for input element of type "file"
    public let fileField: String

    /// Path to template for input element of type "hidden"
    public let hiddenField: String

    /// Path to to template for input element of type "password"
    public let passwordField: String

    /// Path to template for input element of type "text"
    public let textField: String

    /// Path to template for textarea element
    public let textareaField: String

    /// Path to template for select input element
    public let selectField: String

    /// Create a new TagTemplatePaths configuration value.
    ///
    /// - Parameters:
    ///   - checkboxField: path to template for input element of type "checkbox"
    ///   - emailField: path to template for input element of type "email"
    ///   - fileField: path to template for input element of type "file"
    ///   - hiddenField: path to template for input element of type "hidden"
    ///   - passwordField: path to template for input element of type "password"
    ///   - textField: path to template for input element of type "text"
    ///   - textareaField: path to template for input element of type "textarea"
    public init(
        checkboxField: String = "Submissions/Fields/checkbox-input",
        emailField: String = "Submissions/Fields/email-input",
        fileField: String = "Submissions/Fields/file-input",
        hiddenField: String = "Submissions/Fields/hidden-input",
        passwordField: String = "Submissions/Fields/password-input",
        textField: String = "Submissions/Fields/text-input",
        textareaField: String = "Submissions/Fields/textarea-input",
        selectField: String = "Submissions/Fields/select-input"
    ) {
        self.checkboxField = checkboxField
        self.emailField = emailField
        self.fileField = fileField
        self.hiddenField = hiddenField
        self.passwordField = passwordField
        self.textField = textField
        self.textareaField = textareaField
        self.selectField = selectField
    }
}
