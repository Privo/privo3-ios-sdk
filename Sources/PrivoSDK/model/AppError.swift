struct AppError: Decodable, Encodable {
    let code: Int
    let msg: String
}
