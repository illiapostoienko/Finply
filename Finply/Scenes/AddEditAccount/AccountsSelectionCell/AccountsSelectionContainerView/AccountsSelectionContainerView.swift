//
//  AccountsSelectionContainerView.swift
//  Finply
//
//  Created by Illia Postoienko on 10.01.2021.
//

import UIKit
import RxSwift
import RxCocoa

final class AccountsSelectionContainerView: UIView {
    
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
    
    func setup(with viewModels: [AccountSelectionContainerViewModel]) {
        containerStackView.arrangedSubviews.forEach{ $0.removeFromSuperview() }
        
        viewModels.forEach{ viewModel in
            var container = AccountSelectionContainerView.loadFromNib()
            container.bind(to: viewModel)
            containerStackView.addArrangedSubview(container)
        }
    }
}

extension Reactive where Base: AccountsSelectionContainerView {
    
    var items: Binder<[AccountSelectionContainerViewModel]> {
        Binder(self.base) { containerView, items in
            containerView.setup(with: items)
        }
    }
}
