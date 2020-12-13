//
//  Sequence+Extensions.swift
//  Finply
//
//  Created by Illia Postoienko on 30.09.2020.
//

import Foundation
import RxSwift

extension Sequence {
    public func toDictionary<Key: Hashable>(with selectKey: (Iterator.Element) -> Key) -> [Key: Iterator.Element] {
        var dict: [Key: Iterator.Element] = [:]
        for element in self {
            dict[selectKey(element)] = element
        }
        return dict
    }
}
