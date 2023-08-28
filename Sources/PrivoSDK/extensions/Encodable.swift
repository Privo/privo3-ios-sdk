import Foundation

extension Encodable {
    
    func convertToString(encoder: JSONEncoder = .init(),
                         outputFormatting: JSONEncoder.OutputFormatting = .sortedKeys,
                         as sourceEncoding: String.Encoding = .utf8) -> String? {
        encoder.outputFormatting = outputFormatting
        guard let data = try? encoder.encode(self), let stringData = String(data: data, encoding: sourceEncoding) else {
            return nil
        }
        return stringData
    }
    
}
