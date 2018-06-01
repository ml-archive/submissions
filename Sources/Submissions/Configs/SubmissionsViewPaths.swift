public struct SubmissionsViewPaths {
    public let textField: String
    public let emailField: String
    public let passwordField: String

    public init(
        textField: String = "Submissions/Fields/text-input",
        emailField: String = "Submissions/Fields/email-input",
        passwordField: String = "Submissions/Fields/password-input"
    ) {
        self.textField = textField
        self.emailField = emailField
        self.passwordField = passwordField
    }
}
