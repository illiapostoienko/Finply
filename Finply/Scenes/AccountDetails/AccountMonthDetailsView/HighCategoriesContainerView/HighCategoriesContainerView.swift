//
//  HighCategoriesContainerView.swift
//  Finply
//
//  Created by Illia Postoienko on 10.11.2020.
//

import UIKit
import RxSwift
import RxCocoa

final class HighCategoriesContainerView: UIView {
    
    lazy var cells: [HighCategoryContainerView] = {
        (0...4).map { _ -> HighCategoryContainerView in
            let container = HighCategoryContainerView.loadFromNib()
            container.setElementsVisibility(false)
            return container
        }
    }()
    
    lazy var containerStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 7
        cells.forEach { stack.addArrangedSubview($0) }
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
    
    func setup(with items: [HighCategoryContainerItem]) {
        cells.enumerated().forEach{ index, cell in
            guard let item = items[safe: index] else {
                cell.setElementsVisibility(false)
                return
            }
            
            cell.setElementsVisibility(true)
            cell.set(item: item)
        }
    }
}

extension Reactive where Base: HighCategoriesContainerView {
    
    var items: Binder<[HighCategoryContainerItem]> {
        Binder(self.base) { containerView, items in
            containerView.setup(with: items)
        }
    }
}
