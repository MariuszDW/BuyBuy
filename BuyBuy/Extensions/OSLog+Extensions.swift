//
//  OSLog+Extensions.swift
//  BuyBuy
//
//  Created by MDW on 22/09/2025.
//

import Foundation
import os

extension OSLog {
    // In Console.app use filter "subsystem" with "BuyBuy".
    // Example of a log in a code:
    // os_log(.default, log: .main, "Log message %d", 666)
    static let main = OSLog(subsystem: "BuyBuy", category: "main")
}
