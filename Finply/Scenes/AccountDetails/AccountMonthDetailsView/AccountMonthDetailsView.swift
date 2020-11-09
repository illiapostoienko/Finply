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
    }
    
    func bindViewModel() {
        pieChartView.rx
            .didSelectItemAt
            .bind(to: viewModel.itemSelected)
            .disposed(by: bag)
    }
}
