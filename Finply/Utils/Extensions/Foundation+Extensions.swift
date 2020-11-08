//
//  Foundation+Extensions.swift
//  Finply
//
//  Created by Illia Postoienko on 06.11.2020.
//

import Foundation

extension Collection {
    public subscript (safe index: Index) -> Iterator.Element? {
        guard indices.contains(index) else { return nil }
        return self[index]
    }
}
