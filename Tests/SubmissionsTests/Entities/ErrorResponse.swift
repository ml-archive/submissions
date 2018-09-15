struct ErrorResponse: Decodable, Equatable {
    let error: Bool
    let reason: String
    let validationErrors: [String: [String]]
}
