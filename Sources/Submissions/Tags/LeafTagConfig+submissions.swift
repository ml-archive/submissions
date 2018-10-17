import Leaf

extension LeafTagConfig {
    public mutating func useSubmissionsTags(paths: TagTemplatePaths = .init()) {
        use(InputTag(templatePath: paths.emailField), as: "submissions:email")
        use(InputTag(templatePath: paths.passwordField), as: "submissions:password")
        use(InputTag(templatePath: paths.textField), as: "submissions:text")
        use(InputTag(templatePath: paths.hiddenField), as: "submissions:hidden")
        use(InputTag(templatePath: paths.textareaField), as: "submissions:textarea")
    }
}
