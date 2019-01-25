import Vapor

extension File: CustomStringConvertible {
    public var description: String {
        return filename + data.description
    }
}
