//
//  Copyright (c) 2021 Privo Inc. and its affiliates. All rights reserved.
//  Licensed under the Apache License, Version 2.0:
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Foundation

struct CustomServerErrorResponse: Decodable, Hashable, Error {
    
    static var AGE_ESTIMATION_ERROR: Int = 2016
    
    var code: Int
    var errorDescription: String?
    
    enum CodingKeys: String, CodingKey {
        case code
        case error = "msg"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.code = try container.decode(Int.self, forKey: .code)
        self.errorDescription = try container.decodeIfPresent(String.self, forKey: .error)
    }
    
}
