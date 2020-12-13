//
//  OperationSectionModel.swift
//  Finply
//
//  Created by Illia Postoienko on 13.12.2020.
//

import Foundation
import RealmSwift

protocol OperationSectionModelType {
    var id: String { get }
    var sectionDate: Date { get }
    
    // operations
}

final class OperationSectionModel: Object, OperationSectionModelType {
    
    @objc dynamic var id = UUID().uuidString
    
    @objc dynamic var accountId = ""
    @objc dynamic var sectionDate = Date()
    
    var operations = List<OperationModel>()
    let accounts = LinkingObjects(fromType: AccountModel.self, property: "operationSections")
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    convenience init(accountId: String, sectionDate: Date) {
        self.init()
        self.accountId = accountId
        self.sectionDate = sectionDate
    }
}
