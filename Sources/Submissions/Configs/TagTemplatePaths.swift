/// Configuration for template paths used when rendering tags.
public struct TagTemplatePaths {
    /// Path to template for input element of type "email"
    public let emailField: String
    /// Path to to template for input element of type "password"
    public let passwordField: String
    /// Path to template for textarea element
    public let textareaField: String
    /// Path to template for input element of type "text"
    public let textField: String
    /// Path to template for input element of type "hidden"
    public let hiddenField: String
    /// Path to template for input element of type "checkbox"
    public let checkboxField: String

    /// Create a new TagTemplatePaths configuration value.
    ///
    /// - Parameters:
    ///   - emailField: path to template for input element of type "email"
    ///   - passwordField: path to template for input element of type "password"
    ///   - textareaField: path to template for textarea element
    ///   - textField: path to template for input element of type "text"
    public init(
        emailField: String = "Submissions/Fields/email-input",
        passwordField: String = "Submissions/Fields/password-input",
        textareaField: String = "Submissions/Fields/textarea-input",
        textField: String = "Submissions/Fields/text-input",
        hiddenField: String = "Submissions/Fields/hidden-input",
        checkboxField: String = "Submissions/Fields/checkbox-input"
    ) {
        self.emailField = emailField
        self.passwordField = passwordField
        self.textareaField = textareaField
        self.textField = textField
        self.hiddenField = hiddenField
        self.checkboxField = checkboxField
    }
}
