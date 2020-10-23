//
//  Realm+Extensions.swift
//  Finply
//
//  Created by Illia Postoienko on 02.10.2020.
//

import RealmSwift

extension Object {
    static func build<O: Object>(_ builder: (O) -> Void ) -> O {
        let object = O()
        builder(object)
        return object
    }
}
