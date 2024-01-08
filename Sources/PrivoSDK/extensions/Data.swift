import Foundation

extension Data {
    
    func decode<T:Decodable>(decoder: JSONDecoder = .init()) -> T? {
        let object = try? decoder.decode(T.self, from: self)
        return object
    }
    
}
