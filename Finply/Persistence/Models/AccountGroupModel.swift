//
//  AccountGroupModel.swift
//  Finply
//
//  Created by Illia Postoienko on 13.12.2020.
//

import Foundation
import RealmSwift

final class AccountGroupModel: Object {
    
    @objc dynamic var id = UUID().uuidString
    
    @objc dynamic var name = ""
    @objc dynamic var order = 0
    
    var accounts = List<AccountModel>()
    
    override static func primaryKey() -> String? {
        return #keyPath(id)
    }
    
    static var orderKey: String {
        return #keyPath(order)
    }
    
    convenience init(name: String, order: Int) {
        self.init()
        self.name = name
        self.order = order
    }
}
