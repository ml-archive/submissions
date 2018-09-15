struct EncodableViewData<E: Encodable>: Encodable {
    let context: E
    let path: String
}
