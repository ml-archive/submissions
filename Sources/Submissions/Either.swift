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
    public func promoteErrors<E: Error>(ofType type: E.Type = E.self) -> Future<Either<T, E>> {
        return map(Either.left)
            .catchMap {
                guard let error = $0 as? E else {
                    throw $0
                }
                return .right(error)
            }
    }
}
