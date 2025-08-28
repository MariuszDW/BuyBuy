//
//  Bundle+Extenstions.swift
//  BuyBuy
//
//  Created by MDW on 17/05/2025.
//

import Foundation

extension Bundle {
    func appVersion(prefix: String = "", build: Bool = false, suffix: Bool = false, date: Bool = false) -> String {
        let versionString = infoDictionary?["CFBundleShortVersionString"] as? String ?? "0"
        var resultString = "\(prefix)\(versionString)"
        
        if build {
            let buildString = infoDictionary?["CFBundleVersion"] as? String ?? "0"
            resultString += " (\(buildString))"
        }
        
        #if DEBUG
        if suffix {
            resultString += " DEV"
        }
        #endif
        
        if date {
            let dateString = Date().localizedString(dateStyle: .medium, timeStyle: .none) // TODO: Wrong date! This is bug!
            resultString += " (\(dateString))"
        }
        
        return resultString
    }
    
    func appName() -> String {
        return object(forInfoDictionaryKey: "CFBundleName") as? String ?? ""
    }
}
