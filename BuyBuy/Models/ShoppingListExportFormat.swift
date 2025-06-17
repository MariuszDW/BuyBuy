//
//  ShoppingListExportFormat.swift
//  BuyBuy
//
//  Created by MDW on 16/06/2025.
//

import Foundation

enum ShoppingListExportFormat: String, CaseIterable, Identifiable {
    case txt
    case markdown
    case json
    case html
    case amigaGuide
    
    static let `default`: ShoppingListExportFormat = .txt

    var id: String { rawValue }

    func makeExporter() -> ShoppingListExporterProtocol {
        switch self {
        case .txt: return PlainTextShoppingListExporter()
        case .markdown: return PlainTextShoppingListExporter() //  MarkdownShoppingListExporter() // TODO: temporary
        case .json: return PlainTextShoppingListExporter() // JSONShoppingListExporter() // TODO: temporary
        case .html: return PlainTextShoppingListExporter() // HTMLShoppingListExporter() // TODO: temporary
        case .amigaGuide: return PlainTextShoppingListExporter() // AmigaGuideShoppingListExporter() // TODO: temporary
        }
    }

    var localizedName: String {
        switch self {
        case .txt: return "Plain text"
        case .markdown: return "Markdown"
        case .json: return "JSON"
        case .html: return "HTML"
        case .amigaGuide: return "AmigaGuide"
        }
    }

    var fileExtension: String {
        switch self {
        case .txt: return "txt"
        case .markdown: return "md"
        case .json: return "json"
        case .html: return "html"
        case .amigaGuide: return "guide"
        }
    }
}
