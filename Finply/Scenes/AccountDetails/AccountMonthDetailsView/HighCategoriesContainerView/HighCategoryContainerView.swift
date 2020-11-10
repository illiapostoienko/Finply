//
//  HighCategoryContainerView.swift
//  Finply
//
//  Created by Illia Postoienko on 09.11.2020.
//

import UIKit
import RxSwift
import RxCocoa

struct HighCategoryContainerItem: Equatable {
    let color: UIColor
    let categoryName: String
    let value: String
}

final class HighCategoryContainerView: UIView, NibBased {
    
    @IBOutlet private var colorCircleView: UIView!
    @IBOutlet private var categoryNameLabel: UILabel!
    @IBOutlet private var valueLabel: UILabel!
    
    private var currentItem: HighCategoryContainerItem?
    
    func set(item: HighCategoryContainerItem) {
        guard item != currentItem else { return }
        
        currentItem = item
        
        colorCircleView.backgroundColor = item.color
        categoryNameLabel.text = item.categoryName
        valueLabel.text = item.value
        
        setElementsVisibility(true)
    }
    
    func setElementsVisibility(_ isVisible: Bool) {
        colorCircleView.isHidden = !isVisible
        categoryNameLabel.isHidden = !isVisible
        valueLabel.isHidden = !isVisible
    }
}
