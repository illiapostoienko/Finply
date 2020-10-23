//
//  RMCategory.swift
//  Finply
//
//  Created by Illia Postoienko on 01.10.2020.
//

import Foundation
import RealmSwift

final class RMCategory: Object {
    @objc dynamic var id: String = UUID().uuidString
    
    @objc dynamic var name: String = ""
    @objc dynamic var flow: Int = 0
    
    @objc dynamic var order: Int = 0
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
//    override class func indexedProperties() -> [String] {
//        return ["lifeSphere"]
//    }
    
    convenience init(name: String, flow: Int) {
        self.init()
        self.name = name
        self.flow = flow
    }
}

extension RMCategory {
    static func orderKey() -> String {
        return #keyPath(RMCategory.order)
    }
}
