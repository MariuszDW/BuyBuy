//
//  Bundle+Extenstions.swift
//  BuyBuy
//
//  Created by MDW on 17/05/2025.
//

import Foundation

extension Bundle {
    var appVersion: String {
        let version = infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
        let build = infoDictionary?["CFBundleVersion"] as? String ?? "?"
        return "v\(version) (\(build))"
    }
}
