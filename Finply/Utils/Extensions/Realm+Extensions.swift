//
//  Realm+Extensions.swift
//  Finply
//
//  Created by Illia Postoienko on 23.12.2020.
//

import RealmSwift

extension Results {
    func toArray() -> [Element] {
        return Array(self)
    }
}
