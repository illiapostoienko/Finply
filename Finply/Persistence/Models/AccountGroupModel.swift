//
//  AccountGroupModel.swift
//  Finply
//
//  Created by Illia Postoienko on 13.12.2020.
//

import Foundation
import RealmSwift

protocol AccountGroupModelType {
    var id: String { get }
    var name: String { get }
    var order: Int { get }
    
    // color, icon, iconset
}

final class AccountGroupModel: Object, AccountGroupModelType {
    
    @objc dynamic var id = UUID().uuidString
    
    @objc dynamic var name = ""
    @objc dynamic var order = 0
    
    var accounts = List<AccountModel>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    convenience init(name: String, order: Int) {
        self.init()
        self.name = name
        self.order = order
    }
}
