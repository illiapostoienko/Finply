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
            PieChartItem(value: 19.5, color: .black),
            PieChartItem(value: 0.5, color: .clear),
            PieChartItem(value: 19.5, color: .blue),
            PieChartItem(value: 0.5, color: .clear),
            PieChartItem(value: 19.5, color: .red),
            PieChartItem(value: 0.5, color: .clear),
            PieChartItem(value: 19.5, color: .orange),
            PieChartItem(value: 0.5, color: .clear),
            PieChartItem(value: 19.5, color: .cyan),
            PieChartItem(value: 0.5, color: .clear)
        ])
        
        highCategoriesContainer.setup(with: [
            HighCategoryContainerItem(color: .blue, categoryName: "Shops", value: "- $1950"),
            HighCategoryContainerItem(color: .green, categoryName: "Housing", value: "- $1270"),
            HighCategoryContainerItem(color: .purple, categoryName: "Transfers", value: "- $950"),
            HighCategoryContainerItem(color: .systemIndigo, categoryName: "Fuel", value: "- $550"),
            HighCategoryContainerItem(color: .yellow, categoryName: "Other", value: "- $350")
        ])
    }
    
    func bindViewModel() {
        overlapButton.rx
            .tap
            .bind(to: viewModel.reportDetailsTap)
            .disposed(by: bag)
    }
}
