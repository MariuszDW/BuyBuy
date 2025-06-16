//
//  MeasuredUnit.swift
//  BuyBuy
//
//  Created by MDW on 25/05/2025.
//

import Foundation

enum MeasureUnitSystem: String, CaseIterable {
    case metric
    case imperial
    
    var name: String {
        switch self {
        case .metric: return String(localized: "unit_system_metric")
        case .imperial: return String(localized: "unit_system_imperial")
        }
    }
}

enum MeasuredUnitCategory: String, CaseIterable {
    case quantity
    case mass
    case volume
    case length
    
    var name: String {
        switch self {
        case .quantity: return String(localized: "unit_category_quantity")
        case .mass: return String(localized: "unit_category_mass")
        case .volume: return String(localized: "unit_category_volume")
        case .length: return String(localized: "unit_category_length")
        }
    }
    
    var unitSystems: [MeasureUnitSystem] {
        return self == .quantity ? [] : [.metric, .imperial]
    }
    
    func nameWithUnitSystem(_ unitSystem: MeasureUnitSystem) -> String {
        if self == .quantity {
            return self.name
        } else {
            return "\(self.name) (\(unitSystem.name))"
        }
    }
    
    func units(for unitSystem: MeasureUnitSystem = .metric) -> [MeasuredUnit] {
        switch self {
        case .quantity:
            return [.piece]
        case .mass:
            return unitSystem == .metric ? [.microgram, .milligram, .gram, .kilogram] : [.ounce, .pound, .stone]
        case .volume:
            return unitSystem == .metric ? [.milliliter, .liter] : [.teaspoon, .tablespoon, .fluidOunce, .cup, .pint, .quart, .gallon]
        case .length:
            return unitSystem == .metric ? [.millimeter, .centimeter, .meter, .kilometer] : [.inch, .foot, .yard, .mile]
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
    static let `default`: MeasuredUnit = .piece

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
    
    static func buildUnitList(for unitSystems: [MeasureUnitSystem]) -> [(name: String, units: [MeasuredUnit])] {
        var unitList: [(name: String, units: [MeasuredUnit])] = []
        
        for category in MeasuredUnitCategory.allCases {
            if category.unitSystems.isEmpty {
                unitList.append((name: category.name, units: category.units()))
            } else {
                for unitSystem in unitSystems {
                    let units = category.units(for: unitSystem)
                    if !units.isEmpty {
                        let name = unitSystems.count > 1 ? category.nameWithUnitSystem(unitSystem) : category.name
                        unitList.append((name: name, units: units))
                    }
                }
            }
        }

        return unitList
    }
}
