//
//  RMOperation.swift
//  Finply
//
//  Created by Illia Postoienko on 01.10.2020.
//

import Foundation
import RealmSwift

final class RMOperation: Object {
    @objc dynamic var id: String = UUID().uuidString
    
    @objc dynamic var walletId: String = ""
    @objc dynamic var categoryId: String?
    @objc dynamic var value: Double = 0.0
    @objc dynamic var creationDate: Date = Date()
    @objc dynamic var comment: String?
    @objc dynamic var photoPath: String?
    @objc dynamic var flow: Int = 0
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
//    override class func indexedProperties() -> [String] {
//        return ["wallet", "category"]
//    }
    
    convenience init(walletId: UUID,
                     categoryId: UUID? = nil,
                     value: Double,
                     creationDate: Date,
                     comment: String?,
                     photoPath: String?,
                     flow: Int) {
        self.init()
        self.walletId = walletId.uuidString
        self.categoryId = categoryId?.uuidString
        self.value = value
        self.creationDate = creationDate
        self.comment = comment
        self.photoPath = photoPath
        self.flow = flow
    }
}

extension RMOperation {
    static func getByWalletIdPredicate(id: String) -> NSPredicate {
        return NSPredicate(format: "\(#keyPath(RMOperation.walletId)) == %@", id)
    }
}
