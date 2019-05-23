import Leaf
import Sugar

extension LeafTagConfig {

    /// Register Submission's default `InputTag`s using the leaf files determined by the
    /// `TagTemplatePaths` value.
    ///
    /// - Parameter paths: the value containing the leaf paths for the `TnputTag`s.
    public mutating func useSubmissionsLeafTags(paths: TagTemplatePaths = .init()) {
        use([
            "submissions:checkbox": InputTag(templatePath: paths.checkboxField),
            "submissions:email": InputTag(templatePath: paths.emailField),
            "submissions:file": FileTag(templatePath: paths.fileField),
            "submissions:hidden": InputTag(templatePath: paths.hiddenField),
            "submissions:password": InputTag(templatePath: paths.passwordField),
            "submissions:text": InputTag(templatePath: paths.textField),
            "submissions:textarea": InputTag(templatePath: paths.textareaField),
            "submissions:select": SelectTag(templatePath: paths.selectField)
        ])
    }
}
