// TODO: move to sugar

import Vapor

public enum Either<L, R> {
    case left(L)
    case right(R)
}

extension Either: ResponseEncodable where L: ResponseEncodable, R: ResponseEncodable {
    public func encode(for req: Request) throws -> Future<Response> {
        switch self {
        case .left(let left): return try left.encode(for: req)
        case .right(let right): return try right.encode(for: req)
        }
    }
}

extension Future {
    public func promoteSubmissionValidationErrors() -> Future<Either<T, SubmissionValidationError>> {
        return map(Either.left)
            .catchMap {
                guard let error = $0 as? SubmissionValidationError else {
                    throw $0
                }
                return .right(error)
            }
    }
}
