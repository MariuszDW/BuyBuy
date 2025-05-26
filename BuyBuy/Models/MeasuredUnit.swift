//
//  MeasuredUnit.swift
//  BuyBuy
//
//  Created by MDW on 25/05/2025.
//

import Foundation

enum MeasuredUnitCategory: String, CaseIterable {
    case quantity
    case massMetric
    case massImperial
    case volumeMetric
    case volumeImperial
    case lengthMetric
    case lengthImperial
    
    var name: String {
        switch self {
        case .quantity: return "Quantity"
        case .massMetric: return "Mass (Metric)"
        case .massImperial: return "Mass (Imperial)"
        case .volumeMetric: return "Volume (Metric)"
        case .volumeImperial: return "Volume (Imperial)"
        case .lengthMetric: return "Length (Metric)"
        case .lengthImperial: return "Length (Imperial)"
        }
    }
    
    var units: [MeasuredUnit] {
        switch self {
        case .quantity:
            return [.piece]
        case .massMetric:
            return [.microgram, .milligram, .gram, .kilogram]
        case .massImperial:
            return [.ounce, .pound, .stone]
        case .volumeMetric:
            return [.milliliter, .liter]
        case .volumeImperial:
            return [.teaspoon, .tablespoon, .fluidOunce, .cup, .pint, .quart, .gallon]
        case .lengthMetric:
            return [.millimeter, .centimeter, .meter, .kilometer]
        case .lengthImperial:
            return [.inch, .foot, .yard, .mile]
        }
    }
}

enum MeasuredUnit: String, Codable, CaseIterable {
    // quantity
    case piece
    
    // mass/weight - metric units
    case microgram
    case milligram
    case gram
    case kilogram

    // mass/weight - imperial units
    case ounce
    case pound
    case stone

    // volume/capacity - metric units
    case milliliter
    case liter

    // volume/capacity - imperial units
    case teaspoon
    case tablespoon
    case fluidOunce
    case cup
    case pint
    case quart
    case gallon

    // length - metric units
    case millimeter
    case centimeter
    case meter
    case kilometer

    // length - imperial units
    case inch
    case foot
    case yard
    case mile
    
    static private let pieceSymbol = "x"

    private var dimension: Dimension? {
        switch self {
        case .piece:
            return nil
            
        case .microgram:
            return UnitMass.micrograms
        case .milligram:
            return UnitMass.milligrams
        case .gram:
            return UnitMass.grams
        case .kilogram:
            return UnitMass.kilograms
        
        case .ounce:
            return UnitMass.ounces
        case .pound:
            return UnitMass.pounds
        case .stone:
            return UnitMass.stones
            
        case .milliliter:
            return UnitVolume.milliliters
        case .liter:
            return UnitVolume.liters
            
        case .teaspoon:
            return UnitVolume.teaspoons
        case .tablespoon:
            return UnitVolume.tablespoons
        case .fluidOunce:
            return UnitVolume.fluidOunces
        case .cup:
            return UnitVolume.cups
        case .pint:
            return UnitVolume.pints
        case .quart:
            return UnitVolume.quarts
        case .gallon:
            return UnitVolume.gallons
            
        case .millimeter:
            return UnitLength.millimeters
        case .centimeter:
            return UnitLength.centimeters
        case .meter:
            return UnitLength.meters
        case .kilometer:
            return UnitLength.kilometers
            
        case .inch:
            return UnitLength.inches
        case .foot:
            return UnitLength.feet
        case .yard:
            return UnitLength.yards
        case .mile:
            return UnitLength.miles
        }
    }

    var symbol: String {
        if self == .piece {
            return Self.pieceSymbol
        }
        return dimension?.symbol ?? ""
    }
    
    @MainActor
    func format(value: Double, fractionDigits: Int = 2, withUnit: Bool = true) -> String {
        if self == .piece {
            return withUnit ? "\(value)\(symbol)" : "\(value)"
        }
        guard let dimension = dimension else {
            return "\(value)"
        }
        let formatter = Self.formatter(fractionDigits: fractionDigits)
        let measurement = Measurement(value: value, unit: dimension)
        
        if withUnit {
            return formatter.string(from: measurement)
        } else {
            return formatter.numberFormatter.string(from: NSNumber(value: value)) ?? "\(value)"
        }
    }

    @MainActor
    private static func formatter(fractionDigits: Int = 2) -> MeasurementFormatter {
        let formatter = MeasurementFormatter()
        formatter.unitOptions = [.providedUnit]
        formatter.unitStyle = .medium
        formatter.numberFormatter.minimumFractionDigits = 0
        formatter.numberFormatter.maximumFractionDigits = fractionDigits
        return formatter
    }
    
    static func from(symbol: String) -> MeasuredUnit? {
        if symbol.lowercased() == Self.pieceSymbol {
            return .piece
        }
        
        for unit in MeasuredUnit.allCases {
            if let dim = unit.dimension {
                if dim.symbol.lowercased() == symbol.lowercased() {
                    return unit
                }
            }
        }
        return nil
    }
}
