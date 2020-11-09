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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialSetup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialSetup()
    }
    
    private func initialSetup() {
        pieChartView.setup(outerRadius: 78, innerRadius: 50, selectedItemOffset: 15)
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        pieChartView.set(items: [
            PieChartItem(value: 10, color: .black),
            PieChartItem(value: 10, color: .clear),
            PieChartItem(value: 10, color: .blue),
            PieChartItem(value: 10, color: .clear),
            PieChartItem(value: 10, color: .red),
            PieChartItem(value: 10, color: .clear),
            PieChartItem(value: 10, color: .orange),
            PieChartItem(value: 10, color: .clear),
            PieChartItem(value: 10, color: .cyan),
            PieChartItem(value: 10, color: .clear)
        ])
    }
    
    func bindViewModel() {
        pieChartView.rx
            .didSelectItemAt
            .bind(to: viewModel.itemSelected)
            .disposed(by: bag)
    }
}
