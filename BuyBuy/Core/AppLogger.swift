//
//  AppLogger.swift
//  BuyBuy
//
//  Created by MDW on 01/10/2025.
//

import os

// Logger Levels
//
// Method   | OSLogType | Console Visibility
// ---------+-----------+-------------------
// trace    | debug     | hidden by default
// debug    | debug     | hidden by default
// info     | info      | sometimes hidden
// notice   | default   | visible
// warning  | default   | visible
// error    | error     | visible
// critical | fault     | visible
// fault    | fault     | visible

struct AppLogger {
    // Examples:
    // AppLogger.general.info("Test log with public value \(value, privacy: .public)")
    
    static let general = Logger(subsystem: "BuyBuy", category: "general")
}
