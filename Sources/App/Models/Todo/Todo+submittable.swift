import Submissions
import Validation

extension Todo: SubmittableType {
    struct Create: Decodable {
        let title: String
    }

    struct Submission: Decodable {
        let title: String?
    }

    convenience init(_ create: Create) {
        self.init(id: nil, title: create.title)
    }

    func update(_ submission: Submission) {
        if let title = submission.title {
            self.title = title
        }
    }
}

import Vapor

extension Todo.Submission: SubmissionType {
    static let empty = Todo.Submission(title: nil)

    init(_ todo: Todo) {
        title = todo.title
    }

    func makeFields() -> [String: Field] {
        return ["title": Field(label: "Title", value: title, validators: [.count(5...)])]
    }
}
