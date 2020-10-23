//
//  RMAccount.swift
//  Finply
//
//  Created by Illia Postoienko on 01.10.2020.
//

import Foundation
import RealmSwift

final class RMAccount: Object {
    @objc dynamic var id: String = UUID().uuidString
    
    @objc dynamic var name: String = ""
    @objc dynamic var baseValue: Double = 0.0
    @objc dynamic var calculatedValue: Double = 0.0
    @objc dynamic var order: Int = 0
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    convenience init(name: String, baseValue: Double, calculatedValue: Double, order: Int) {
        self.init()
        self.name = name
        self.baseValue = baseValue
        self.calculatedValue = calculatedValue
        self.order = order
    }
}

extension RMAccount {
    static func orderKey() -> String {
        return #keyPath(RMAccount.order)
    }
}
