//
//  Sequence+Extensions.swift
//  Finply
//
//  Created by Illia Postoienko on 30.09.2020.
//

import Foundation
import RxSwift

extension Sequence where Iterator.Element: DomainEntityConvertibleType {
    func mapToDomain() -> [Element.DomainEntityType] {
        return map {
            return $0.toDomain()
        }
    }
}

extension Sequence where Iterator.Element: RealmConvertibleType {
    func mapToRealm() -> [Element.RealmType] {
        return map {
            return $0.toRealm()
        }
    }
}

extension Sequence {
    public func toDictionary<Key: Hashable>(with selectKey: (Iterator.Element) -> Key) -> [Key: Iterator.Element] {
        var dict: [Key: Iterator.Element] = [:]
        for element in self {
            dict[selectKey(element)] = element
        }
        return dict
    }
}
