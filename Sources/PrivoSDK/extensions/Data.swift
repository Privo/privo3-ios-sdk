//
//  Copyright (c) 2021-2024 Privacy Vaults Online, Inc. and its affiliates. All rights reserved.
//  Licensed under the Apache License, Version 2.0:
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Foundation

extension Data {
    
    func decode<T:Decodable>(decoder: JSONDecoder = .init()) -> T? {
        let object = try? decoder.decode(T.self, from: self)
        return object
    }
    
}
