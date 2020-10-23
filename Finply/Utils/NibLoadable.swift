//
//  NibLoadable.swift
//  Finply
//
//  Created by Illia Postoienko on 30.09.2020.
//

import Foundation
import UIKit

open class NibLoadable: UIView {
    @objc dynamic open var nibContainerView: UIView { return self }
    @objc dynamic open var nibName: String { return String(describing: type(of: self)) }
    @objc dynamic open var nibBundle: Bundle { return Bundle(for: type(of: self)) }
        
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupNib()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupNib()
    }
    
    open func setupNib() {
        guard let view = nibBundle.loadNibNamed(nibName, owner: self, options: nil)?.first as? UIView else {
            fatalError("Failed to load view \(String(describing: self)) from nib \"\(nibName)\".")
        }
        let container = nibContainerView
        container.backgroundColor = .clear
        container.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        let bindings = ["view": view]
        container.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: [], metrics: nil, views: bindings))
        container.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: [], metrics: nil, views: bindings))
    }
}
