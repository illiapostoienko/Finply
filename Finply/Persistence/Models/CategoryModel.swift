//
//  CategoryModel.swift
//  Finply
//
//  Created by Illia Postoienko on 13.12.2020.
//

import Foundation
import RealmSwift

protocol CategoryModelType: OrderableType {
    var id: String { get }
    var name: String { get }
    var categoryType: CategoryModel.CategoryType { get }
    
    // color, icon,
    
    func updateProperties(name: String, categoryType: CategoryModel.CategoryType)
}

//swiftlint:disable force_unwrapping
final class CategoryModel: Object, CategoryModelType {
    
    @objc dynamic var id = UUID().uuidString
    
    @objc dynamic var name = ""
    @objc dynamic private var categoryTypeId: Int = 0
    @objc dynamic var order = 0
    
    @objc dynamic var parentCategory: CategoryModel?
    
    var categoryType: CategoryType {
        get{ return CategoryType(rawValue: categoryTypeId)! }
        set{ categoryTypeId = newValue.rawValue }
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    convenience init(name: String, categoryType: CategoryType) {
        self.init()
        self.name = name
        self.categoryType = categoryType
    }
    
    enum CategoryType: Int {
        case income
        case expense
    }
    
    weak var repositoryDelegate: RealmRepositoryDelegate?
    
    func updateOrder(to order: Int) {
        repositoryDelegate?.selfUpdate(modelAction: { [unowned self] () -> [Object] in
            let updatingSelf = self
            updatingSelf.order = order
            return [updatingSelf]
        })
    }
    
    func updateProperties(name: String, categoryType: CategoryType) {
        repositoryDelegate?.selfUpdate(modelAction: { [unowned self] () -> [Object] in
            let updatingSelf = self
            updatingSelf.name = name
            updatingSelf.categoryType = categoryType
            return [updatingSelf]
        })
    }
}
