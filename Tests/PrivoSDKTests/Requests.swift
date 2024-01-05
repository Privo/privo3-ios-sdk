//
//  Copyright (c) 2021 Privo Inc. and its affiliates. All rights reserved.
//  Licensed under the Apache License, Version 2.0:
//  http://www.apache.org/licenses/LICENSE-2.0
//

import Foundation
@testable import PrivoSDK

fileprivate extension URLRequest {
    var data: Data? {
        let request = self
        if let stream = request.httpBodyStream {
            let bufferLength = 1024
            var buffer = [UInt8](repeating: 0, count: bufferLength)

            if stream.streamStatus != .notOpen {
                stream.close()
            }
            stream.open()
            
            var result: Data = Data() // empty data
            while stream.hasBytesAvailable {
                let bytesRead = stream.read(&buffer, maxLength: buffer.count)
                if bytesRead > 0 {
                    result.append(contentsOf: buffer.prefix(bytesRead))
                } else if bytesRead < 0 {
                    // inputStream.streamError was happened
                    break
                } else {
                    // nothing data to read (perhaps, at the end of the stream)
                    break
                }
            }
            stream.close()
            return result
        } else {
            return request.httpBody
        }
    }
}


extension URLRequest {
    var analyticEvent: AnalyticEvent? {
        guard let data = self.data else {
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            let analyticEvent = try decoder.decode(AnalyticEvent.self, from: data)
            return analyticEvent
        } catch {
            return nil
        }
    }
    
    var analyticEventErrorData: AnalyticEventErrorData? {
        guard let data = self.analyticEvent?.data?.data(using: .utf8) else {
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            let analyticEvent = try decoder.decode(AnalyticEventErrorData.self, from: data)
            return analyticEvent
        } catch {
            return nil
        }
    }
}
