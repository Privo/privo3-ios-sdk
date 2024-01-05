//
//  Copyright (c) 2021 Privo Inc. and its affiliates. All rights reserved.
//  Licensed under the Apache License, Version 2.0:
//  http://www.apache.org/licenses/LICENSE-2.0
//

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
