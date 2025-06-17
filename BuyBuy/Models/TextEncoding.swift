//
//  TextEncoding.swift
//  BuyBuy
//
//  Created by MDW on 17/06/2025.
//

import Foundation

enum TextEncoding: String, CaseIterable, Identifiable {
    case utf8 = "UTF-8"
    case utf16 = "UTF-16"
    case ascii = "ASCII"
    case isoLatin1 = "ISO-8859-1"
    case isoLatin2 = "ISO-8859-2"
    
    static let `default`: TextEncoding = .utf8
    
    var id: String { rawValue }

    var stringEncoding: String.Encoding {
        switch self {
        case .utf8:
            return .utf8
        case .utf16:
            return .utf16
        case .ascii:
            return .ascii
        case .isoLatin1:
            return .isoLatin1
        case .isoLatin2:
            return .isoLatin2
        }
    }
    
    var mayLoseInformation: Bool {
        switch self {
        case .utf8, .utf16:
            return false
        case .ascii, .isoLatin1, .isoLatin2:
            return true
        }
    }
}
