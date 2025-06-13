//
//  Bundle+Extenstions.swift
//  BuyBuy
//
//  Created by MDW on 17/05/2025.
//

import Foundation

extension Bundle {
    func appVersion(prefix: String = "", build: Bool = false, date: Bool = false) -> String {
        let versionString = infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
        let buildString = infoDictionary?["CFBundleVersion"] as? String ?? "?"
        
        var resultString = "\(prefix)\(versionString)"
        
        if build {
            resultString = resultString + " (\(buildString))"
        }
        
        if date {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            formatter.locale = Locale.current
            let dateString = formatter.string(from: Date())
            resultString += " (\(dateString))"
        }
        
        return resultString
    }
}
