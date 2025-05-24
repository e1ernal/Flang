//
//  Source.swift
//  Flang
//
//  Created by e1ernal on 21.05.2025.
//

import Foundation

struct Source: Decodable {
    let name: String
    let nameShort: String
    let nameNative: String
    let nameNativeShort: String
    
    let flagEmoji: String
    let flagCode: String
    let flagImage: Data?
    
    private enum CodingKeys: String, CodingKey {
        case name
        case nameShort = "name_short"
        case nameNative = "name_native"
        case nameNativeShort = "name_native_short"
        
        case flagEmoji = "flag_emoji"
        case flagCode = "flag_code"
        case flagImage = "flag_image"
    }
}

