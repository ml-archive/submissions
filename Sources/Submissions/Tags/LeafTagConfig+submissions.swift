import Leaf
import Sugar

extension LeafTagConfig {

    /// Register Submission's default `InputTag`s using the leaf files determined by the
    /// `TagTemplatePaths` value.
    ///
    /// - Parameter paths: the value containing the leaf paths for the `TnputTag`s.
    public mutating func useSubmissionsTags(paths: TagTemplatePaths = .init()) {
        use([
            "submissions:email": InputTag(templatePath: paths.emailField),
            "submissions:password": InputTag(templatePath: paths.passwordField),
            "submissions:text": InputTag(templatePath: paths.textField),
            "submissions:hidden": InputTag(templatePath: paths.hiddenField),
            "submissions:textarea": InputTag(templatePath: paths.textareaField)
        ])
    }
}
