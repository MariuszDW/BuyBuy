//
//  Bundle+Extenstions.swift
//  BuyBuy
//
//  Created by MDW on 17/05/2025.
//

import Foundation

extension Bundle {
    func appVersion(build: Bool = false) -> String {
        var versionString = infoDictionary?["CFBundleShortVersionString"] as? String ?? "0"
        
        if build {
            let buildString = infoDictionary?["CFBundleVersion"] as? String ?? "0"
            versionString += " (\(buildString))"
        }
        
        return versionString
    }
    
    func appName() -> String {
        return object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? ""
    }
    
    func appReleaseDate() -> Date? {
        guard let releaseDateString = Bundle.main.infoDictionary?["APP_RELEASE_DATE"] as? String else {
            return nil
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.date(from: releaseDateString)
    }
}
