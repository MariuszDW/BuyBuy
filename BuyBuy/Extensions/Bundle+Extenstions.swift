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
            resultString += " (\(buildString))"
        }
        
        if date {
            let dateString = Date().localizedString(dateStyle: .medium, timeStyle: .none)
            resultString += " (\(dateString))"
        }
        
        return resultString
    }
    
    func appName() -> String {
        return object(forInfoDictionaryKey: "CFBundleName") as? String ?? ""
    }
}
