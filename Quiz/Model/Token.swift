
struct TokenResponse: Decodable {
    let responseCode: Int
    let responseMessage: String
    let token: String
}
