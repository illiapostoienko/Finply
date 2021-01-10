//
//  AccountSelectionContainerView.swift
//  Finply
//
//  Created by Illia Postoienko on 10.01.2021.
//

import UIKit
import RxSwift
import RxCocoa

final class AccountSelectionContainerView: UIView, NibBased, BindableType {
    
    @IBOutlet private var iconBaseView: GradientView!
    @IBOutlet private var iconImageView: UIImageView!
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var valueLabel: UILabel!
    @IBOutlet private var checkImageView: UIImageView!
    @IBOutlet private var coveringButton: UIButton!
    
    var viewModel: AccountSelectionContainerViewModel!
    
    private let formatter = CurrencyFormatter()
    private let bag = DisposeBag()
    
    func bindViewModel() {
        viewModel.isSelected
            .map{ !$0 }
            .bind(to: checkImageView.rx.isHidden)
            .disposed(by: bag)
        
        coveringButton.rx.tap
            .bind(to: viewModel.tap)
            .disposed(by: bag)
        
        nameLabel.text = viewModel.account.name
        
        formatter.currency = viewModel.account.currency
        let doubleValue = Double(viewModel.account.calculatedValueInCents) / Double(100)
        valueLabel.text = formatter.string(from: doubleValue)
    }
}

final class AccountSelectionContainerViewModel {
    
    let tap = PublishSubject<Void>()
    
    let isSelected: BehaviorRelay<Bool>
    let account: AccountDto
    
    private let bag = DisposeBag()
    
    init(isSelected: Bool, account: AccountDto) {
        self.isSelected = BehaviorRelay<Bool>(value: isSelected)
        self.account = account
        
        tap.withLatestFrom(self.isSelected)
            .map{ !$0 }
            .bind(to: self.isSelected)
            .disposed(by: bag)
    }
}
