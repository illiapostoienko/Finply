//
//  AccountsInGroupContainerView.swift
//  Finply
//
//  Created by Illia Postoienko on 13.12.2020.
//

import UIKit
import RxSwift
import RxCocoa

final class AccountsInGroupContainerView: UIView {
    
    lazy var containerStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 5
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        addSubview(containerStackView)
        containerStackView.translatesAutoresizingMaskIntoConstraints = false
        leadingAnchor.constraint(equalTo: containerStackView.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: containerStackView.trailingAnchor).isActive = true
        topAnchor.constraint(equalTo: containerStackView.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: containerStackView.bottomAnchor).isActive = true
    }
    
    func setup(with items: [AccountInGroupContainerItem]) {
        
        containerStackView.arrangedSubviews.forEach{ $0.removeFromSuperview() }
        
        items.forEach{ item in
            let container = AccountInGroupContainerView.loadFromNib()
            container.set(item: item)
            containerStackView.addArrangedSubview(container)
        }
    }
}

extension Reactive where Base: AccountsInGroupContainerView {
    
    var items: Binder<[AccountInGroupContainerItem]> {
        Binder(self.base) { containerView, items in
            containerView.setup(with: items)
        }
    }
}
