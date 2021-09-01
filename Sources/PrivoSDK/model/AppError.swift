//
//  File.swift
//  
//
//  Created by alex slobodeniuk on 09.06.2021.
//

struct AppError: Decodable, Encodable {
    let code: Int
    let msg: String
}
