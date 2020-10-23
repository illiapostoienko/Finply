//
//  NibBased.swift
//  Finply
//
//  Created by Illia Postoienko on 30.09.2020.
//

import UIKit

typealias NibReusable = Reusable & NibBased

protocol NibBased: class {
    static var nib: UINib { get }
}

extension NibBased {
    static var nib: UINib {
        return UINib(nibName: String(describing: self), bundle: Bundle(for: self))
    }
}

extension NibBased where Self: UIView {
    static func loadFromNib() -> Self {
        guard let view = nib.instantiate(withOwner: nil, options: nil).first as? Self else {
            fatalError("The nib \(nib) expected its root view to be of type \(self)")
        }
        return view
    }
}
