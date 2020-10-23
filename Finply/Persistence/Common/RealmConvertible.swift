//
//  RealmConvertible.swift
//  Finply
//
//  Created by Illia Postoienko on 02.10.2020.
//

import Foundation

protocol RealmConvertibleType {
    associatedtype RealmType: DomainEntityConvertibleType

    var id: UUID { get }

    func toRealm() -> RealmType
}
