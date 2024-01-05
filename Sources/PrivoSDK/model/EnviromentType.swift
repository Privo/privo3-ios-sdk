//
//  Copyright (c) 2021 Privo Inc. and its affiliates. All rights reserved.
//  Licensed under the Apache License, Version 2.0:
//  http://www.apache.org/licenses/LICENSE-2.0
//

public enum EnviromentType: Int, Equatable, CaseIterable, Encodable {
    case Local = 0
    case Dev
    case Int
    case Test
    case Prod
}

// conforms Decodable for test purposes
extension EnviromentType: Decodable {}
