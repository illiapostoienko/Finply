//
//  AccountMonthDetailsView.swift
//  Finply
//
//  Created by Illia Postoienko on 06.11.2020.
//

import UIKit
import RxSwift
import RxCocoa

final class AccountMonthDetailsView: NibLoadable, BindableType {
    
    @IBOutlet private var pieChartView: PieChartView!
    @IBOutlet private var highCategoriesContainer: HighCategoriesContainerView!
    @IBOutlet private var incomesLabel: UILabel!
    @IBOutlet private var expensesLabel: UILabel!
    @IBOutlet private var monthLabel: UILabel!
    @IBOutlet private var yearLabel: UILabel!
    @IBOutlet private var overlapButton: UIButton!
    
    var viewModel: AccountMonthDetailsViewModelType!
    
    private let bag = DisposeBag()
    
    override func setupNib() {
        super.setupNib()
        pieChartView.setup(innerRadiusMultiplier: 0.64)
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        pieChartView.set(items: [
            PieChartItem(value: 19.5, color: #colorLiteral(red: 0.6235294118, green: 0.8588235294, blue: 0.9843137255, alpha: 1)),
            PieChartItem(value: 0.5, color: .clear),
            PieChartItem(value: 19.5, color: #colorLiteral(red: 0.7137254902, green: 0.7764705882, blue: 0.8392156863, alpha: 1)),
            PieChartItem(value: 0.5, color: .clear),
            PieChartItem(value: 19.5, color: #colorLiteral(red: 0.9294117647, green: 0.3960784314, blue: 0.3725490196, alpha: 1)),
            PieChartItem(value: 0.5, color: .clear),
            PieChartItem(value: 19.5, color: #colorLiteral(red: 0.2901960784, green: 0.3647058824, blue: 0.9058823529, alpha: 1)),
            PieChartItem(value: 0.5, color: .clear),
            PieChartItem(value: 19.5, color: #colorLiteral(red: 0.9764705882, green: 0.8196078431, blue: 0.5960784314, alpha: 1)),
            PieChartItem(value: 0.5, color: .clear)
        ])
        
        highCategoriesContainer.setup(with: [
            HighCategoryContainerItem(color: #colorLiteral(red: 0.6235294118, green: 0.8588235294, blue: 0.9843137255, alpha: 1), categoryName: "Shops", value: "- $1950"),
            HighCategoryContainerItem(color: #colorLiteral(red: 0.7137254902, green: 0.7764705882, blue: 0.8392156863, alpha: 1), categoryName: "Housing", value: "- $1270"),
            HighCategoryContainerItem(color: #colorLiteral(red: 0.9294117647, green: 0.3960784314, blue: 0.3725490196, alpha: 1), categoryName: "Transfers", value: "- $950"),
            HighCategoryContainerItem(color: #colorLiteral(red: 0.2901960784, green: 0.3647058824, blue: 0.9058823529, alpha: 1), categoryName: "Fuel", value: "- $550"),
            HighCategoryContainerItem(color: #colorLiteral(red: 0.9764705882, green: 0.8196078431, blue: 0.5960784314, alpha: 1), categoryName: "Other", value: "- $350")
        ])
    }
    
    func bindViewModel() {
        overlapButton.rx
            .tap
            .bind(to: viewModel.reportDetailsTap)
            .disposed(by: bag)
    }
    
    func adjustLayout(by percent: CGFloat) {
        alpha = 1 - percent
    }
}
