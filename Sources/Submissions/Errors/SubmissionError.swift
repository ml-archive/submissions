import Vapor

enum SubmissionError: Error {
    case invalidPathForKeyPath
}

extension SubmissionError: AbortError {
    var identifier: String {
        switch self {
        case .invalidPathForKeyPath: return "invalidPathForKeyPath"
        }
    }

    var reason: String {
        switch self {
        case .invalidPathForKeyPath: return "Invalid Path for KeyPath"
        }
    }

    var status: HTTPResponseStatus {
        return .internalServerError
    }
}
