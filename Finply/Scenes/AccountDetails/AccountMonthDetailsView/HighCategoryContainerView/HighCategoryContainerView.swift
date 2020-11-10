//
//  HighCategoryContainerView.swift
//  Finply
//
//  Created by Illia Postoienko on 09.11.2020.
//

import UIKit

struct HighCategoryContainerModel: Equatable {
    let color: UIColor
    let categoryName: String
    let value: String
}

final class HighCategoryContainerView: NibLoadable {
    
    @IBOutlet private var colorCircleView: UIView!
    @IBOutlet private var categoryNameLabel: UILabel!
    @IBOutlet private var valueLabel: UILabel!
    
    private var currentModel: HighCategoryContainerModel? = nil
    
    override func setupNib() {
        super.setupNib()
        setElementsVisibility(false)
    }
    
    func setup(with model: HighCategoryContainerModel) {
        guard model != currentModel else { return }
        
        colorCircleView.backgroundColor = model.color
        categoryNameLabel.text = model.categoryName
        valueLabel.text = model.value
        
        setElementsVisibility(true)
    }
    
    func setElementsVisibility(_ isVisible: Bool) {
        colorCircleView.isHidden = !isVisible
        categoryNameLabel.isHidden = !isVisible
        valueLabel.isHidden = !isVisible
    }
}
