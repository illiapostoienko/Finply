//
//  Reusable.swift
//  Finply
//
//  Created by Illia Postoienko on 30.09.2020.
//

import UIKit

protocol Reusable: class {
    static var reuseIdentifier: String { get }
}

extension Reusable {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}
