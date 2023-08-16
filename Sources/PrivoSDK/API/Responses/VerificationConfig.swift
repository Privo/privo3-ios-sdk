struct VerificationConfig: Encodable {
    let apiKey: String
    let siteIdentifier: String
    let displayMode = "redirect"
    let transparentBackground = true
}
