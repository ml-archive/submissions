/// Configuration for template paths used when rendering tags.
public struct TagTemplatePaths {
    /// Path to template for input of type "text"
    public let textField: String
    /// Path to template for input of type "email"
    public let emailField: String
    /// Path to template for input of type "password"
    public let passwordField: String
    /// Path to template for textarea
    public let textareaField: String

    /// Create a new TagTemplatePaths configuration value.
    ///
    /// - Parameters:
    ///   - textField: path to template for input of type "text"
    ///   - emailField: path to template for input of type "email"
    ///   - passwordField: path to template for input of type "password"
    ///   - textareaField: path to template for textarea
    public init(
        textField: String = "Submissions/Fields/text-input",
        emailField: String = "Submissions/Fields/email-input",
        passwordField: String = "Submissions/Fields/password-input",
        textareaField: String = "Submissions/Fields/textarea-input"
    ) {
        self.textField = textField
        self.emailField = emailField
        self.passwordField = passwordField
        self.textareaField = textareaField
    }
}
