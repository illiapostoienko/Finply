//
//  CurrencyFormatter.swift
//  Finply
//
//  Created by Illia Postoienko on 24.12.2020.
//

import Foundation

final class CurrencyFormatter {
    
    var currency: Currency {
        set { numberFormatter.currencyCode = newValue.rawValue }
        get { Currency(rawValue: numberFormatter.currencyCode) ?? .dollar }
    }
    
    let numberFormatter: NumberFormatter
    
    init(_ currency: Currency? = nil) {
        numberFormatter = NumberFormatter()
        numberFormatter.alwaysShowsDecimalSeparator = false
        numberFormatter.numberStyle = .currency
        
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
        numberFormatter.minimumIntegerDigits = 1
        numberFormatter.locale = .current
        currency.map{ numberFormatter.currencyCode = $0.rawValue }
    }
    
    public func string(from double: Double) -> String? {
        return numberFormatter.string(from: double)
    }
    
    public func double(from string: String) -> Double? {
        Double(string)
    }
}

public extension NumberFormatter {
    
    func string(from doubleValue: Double?) -> String? {
        if let doubleValue = doubleValue {
            return string(from: NSNumber(value: doubleValue))
        }
        return nil
    }
}
