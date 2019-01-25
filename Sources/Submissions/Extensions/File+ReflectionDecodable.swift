import Vapor

extension File: Equatable {
    public static func == (lhs: File, rhs: File) -> Bool {
        return lhs.data == rhs.data && lhs.filename == rhs.filename
    }
}

extension File: ReflectionDecodable {
    public static func reflectDecodedIsLeft(_ item: File) throws -> Bool {
        return try item == self.reflectDecoded().0
    }
    
    /// See `ReflectionDecodable.reflectDecoded()` for more information.
    public static func reflectDecoded() throws -> (File, File) {
        let left = File(data: Data([0x00]), filename: "")
        let right = File(data: Data([0x01]), filename: "")
        return (left, right)
    }
}

