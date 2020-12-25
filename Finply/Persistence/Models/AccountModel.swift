//
//  AccountModel.swift
//  Finply
//
//  Created by Illia Postoienko on 24.12.2020.
//

import Foundation
import RealmSwift

//swiftlint:disable force_unwrapping
final class AccountModel: Object {
    
    @objc dynamic var id = UUID().uuidString
    
    @objc dynamic var name: String = ""
    @objc dynamic var baseValueInCents: Int = 0
    @objc dynamic var calculatedValueInCents: Int = 0
    @objc dynamic private var currencyCode = "USD"
    @objc dynamic var order = 0
    
    var operationSections = List<OperationSectionModel>()
    
    var currency: Currency {
        get{ return Currency(rawValue: currencyCode)! }
        set{ currencyCode = newValue.rawValue }
    }
    
    override static func primaryKey() -> String? {
        return #keyPath(id)
    }
    
    static var orderKey: String {
        return #keyPath(order)
    }
    
    convenience init(name: String, baseValueInCents: Int, calculatedValueInCents: Int, currency: Currency, order: Int) {
        self.init()
        self.name = name
        self.baseValueInCents = baseValueInCents
        self.calculatedValueInCents = calculatedValueInCents
        self.currency = currency
        self.order = order
    }
}
