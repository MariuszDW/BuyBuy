//
//  ExportedData.swift
//  BuyBuy
//
//  Created by MDW on 16/06/2025.
//

import Foundation

struct ExportedData: Identifiable {
    let id = UUID()
    let data: Data
    let fileName: String
    let fileExtension: String
}
