//
//  UnitConversion.swift
//  jimu
//
//  Created by Jimu Team on 18/1/2026.
//

import Foundation

// MARK: - Unit Converter
/// Utility for converting between units based on user settings
/// Database stores all values in metric (kg, km, cm)
struct UnitConverter {
    
    // MARK: - Weight Conversion
    
    /// Converts weight from kg (database) to display unit
    static func displayWeight(_ weightInKg: Double, unit: WeightUnit) -> Double {
        weightInKg * unit.fromKgFactor
    }
    
    /// Converts weight from display unit to kg (for database)
    static func storeWeight(_ weight: Double, from unit: WeightUnit) -> Double {
        weight * unit.toKgFactor
    }
    
    /// Formats weight for display with unit suffix
    static func formatWeight(_ weightInKg: Double, unit: WeightUnit, decimals: Int = 1) -> String {
        let displayValue = displayWeight(weightInKg, unit: unit)
        let formatted = String(format: "%.\(decimals)f", displayValue)
        return "\(formatted) \(unit.displayName)"
    }
    
    // MARK: - Distance Conversion
    
    /// Converts distance from km (database) to display unit
    static func displayDistance(_ distanceInKm: Double, unit: DistanceUnit) -> Double {
        distanceInKm * unit.fromKmFactor
    }
    
    /// Converts distance from display unit to km (for database)
    static func storeDistance(_ distance: Double, from unit: DistanceUnit) -> Double {
        distance * unit.toKmFactor
    }
    
    /// Formats distance for display with unit suffix
    static func formatDistance(_ distanceInKm: Double, unit: DistanceUnit, decimals: Int = 2) -> String {
        let displayValue = displayDistance(distanceInKm, unit: unit)
        let formatted = String(format: "%.\(decimals)f", displayValue)
        return "\(formatted) \(unit.displayName)"
    }
    
    // MARK: - Length Conversion
    
    /// Converts length from cm (database) to display unit
    static func displayLength(_ lengthInCm: Double, unit: LengthUnit) -> Double {
        switch unit {
        case .cm:
            return lengthInCm
        case .inch:
            return lengthInCm / 2.54
        }
    }
    
    /// Converts length from display unit to cm (for database)
    static func storeLength(_ length: Double, from unit: LengthUnit) -> Double {
        switch unit {
        case .cm:
            return length
        case .inch:
            return length * 2.54
        }
    }
}

// MARK: - Double Extension for Convenient Conversion
extension Double {
    /// Converts from kg to the specified unit
    func toWeightUnit(_ unit: WeightUnit) -> Double {
        UnitConverter.displayWeight(self, unit: unit)
    }
    
    /// Converts from the specified unit to kg
    func fromWeightUnit(_ unit: WeightUnit) -> Double {
        UnitConverter.storeWeight(self, from: unit)
    }
    
    /// Formats as weight string with the specified unit
    func formatAsWeight(unit: WeightUnit, decimals: Int = 1) -> String {
        UnitConverter.formatWeight(self, unit: unit, decimals: decimals)
    }
    
    /// Converts from km to the specified unit
    func toDistanceUnit(_ unit: DistanceUnit) -> Double {
        UnitConverter.displayDistance(self, unit: unit)
    }
    
    /// Converts from the specified unit to km
    func fromDistanceUnit(_ unit: DistanceUnit) -> Double {
        UnitConverter.storeDistance(self, from: unit)
    }
}

// MARK: - WorkoutSet Extension for Unit-Aware Display
extension WorkoutSet {
    /// Returns weight formatted with the user's preferred unit
    func formattedWeight(unit: WeightUnit) -> String {
        // Assuming weight is stored in kg
        let displayWeight = weight.toWeightUnit(unit)
        if displayWeight == 0 {
            return "0"
        }
        
        // Remove unnecessary decimals
        if displayWeight.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", displayWeight)
        } else {
            return String(format: "%.1f", displayWeight)
        }
    }
    
    /// Returns formatted string with user's unit (e.g., "60kg × 10回" or "132lbs × 10回")
    func formattedString(unit: WeightUnit) -> String {
        let weightStr = formattedWeight(unit: unit)
        if weight > 0 {
            return "\(weightStr)\(unit.displayName.lowercased()) × \(reps)回"
        } else {
            return "\(reps)回"
        }
    }
}

// MARK: - Input Parsing
extension UnitConverter {
    
    /// Parses a weight string and returns the value in kg
    /// Handles inputs like "200 lbs", "90.5 kg", "200lbs", etc.
    static func parseWeight(_ input: String, defaultUnit: WeightUnit) -> Double? {
        let trimmed = input.trimmingCharacters(in: .whitespaces).lowercased()
        
        // Try to extract number and unit
        let pattern = #"^([\d.]+)\s*(kg|lbs|lb)?$"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return nil
        }
        
        let range = NSRange(location: 0, length: trimmed.utf16.count)
        guard let match = regex.firstMatch(in: trimmed, options: [], range: range) else {
            // Just a number, use default unit
            if let value = Double(trimmed) {
                return storeWeight(value, from: defaultUnit)
            }
            return nil
        }
        
        guard let numberRange = Range(match.range(at: 1), in: trimmed),
              let value = Double(String(trimmed[numberRange])) else {
            return nil
        }
        
        // Check for unit
        if match.range(at: 2).location != NSNotFound,
           let unitRange = Range(match.range(at: 2), in: trimmed) {
            let unitStr = String(trimmed[unitRange])
            let unit: WeightUnit = (unitStr == "lbs" || unitStr == "lb") ? .lbs : .kg
            return storeWeight(value, from: unit)
        }
        
        // No unit specified, use default
        return storeWeight(value, from: defaultUnit)
    }
}

