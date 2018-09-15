struct DecodableViewData<D: Decodable>: Decodable {
    let context: D
    let path: String
}
