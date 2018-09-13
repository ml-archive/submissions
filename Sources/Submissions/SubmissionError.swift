import Vapor

enum SubmissionError: Error {
    case invalidPathForKeyPath
    case requestNotPassedIntoRender
}

extension SubmissionError: AbortError {
    var identifier: String {
        switch self {
        case .invalidPathForKeyPath: return "invalidPathForKeyPath"
        case .requestNotPassedIntoRender: return "requestNotPassedInToRender"
        }
    }

    var reason: String {
        switch self {
        case .invalidPathForKeyPath: return "Invalid Path for KeyPath"
        case .requestNotPassedIntoRender: return "Request not passed into render call."
        }
    }

    var status: HTTPResponseStatus {
        return .internalServerError
    }
}
