import Foundation

extension Encodable {
    
    func convertToString(encoder: JSONEncoder = .init(), as sourceEncoding: String.Encoding = .utf8) -> String? {
        guard let data = try? encoder.encode(self), let stringData = String(data: data, encoding: sourceEncoding) else {
            return nil
        }
        return stringData
    }
    
}
