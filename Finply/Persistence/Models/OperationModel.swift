//
//  OperationModel.swift
//  Finply
//
//  Created by Illia Postoienko on 13.12.2020.
//

import Foundation
import RealmSwift

// swiftlint:disable force_unwrapping
final class OperationModel: Object {
    
    @objc dynamic var id = UUID().uuidString
    
    @objc dynamic var accountId = ""
    @objc dynamic var operationSectionId = ""
    @objc dynamic var categoryId = ""
    
    @objc dynamic var creationDate = Date()
    @objc dynamic var operationDate = Date()
    @objc dynamic var valueInCents: Int = 0
    @objc dynamic var comment: String?
    @objc dynamic var photoPath: String?
    @objc dynamic private var operationTypeId = OperationType.expense.rawValue
    
    // Relations
    @objc dynamic var category: CategoryModel?
    let sections = LinkingObjects(fromType: OperationSectionModel.self, property: "operations")
    
    var operationType: OperationType {
        get{ return OperationType(rawValue: operationTypeId)! }
        set{ operationTypeId = newValue.rawValue }
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    convenience init(accountId: String, operationSectionId: String, categoryId: String, creationDate: Date, operationDate: Date, valueInCents: Int, comment: String?, photoPath: String?, operationKind: OperationType) {
        self.init()
        self.accountId = accountId
        self.operationSectionId = operationSectionId
        self.categoryId = categoryId
        self.creationDate = creationDate
        self.operationDate = operationDate
        self.valueInCents = valueInCents
        self.comment = comment
        self.photoPath = photoPath
        self.operationType = operationKind
    }
    
    enum OperationType: Int {
        case expense
        case income
        case expenseToCategory
        case incomeFromCategory
        case expenseToAccount
        case incomeFromAccount
    }
}
