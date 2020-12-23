//
//  BallanceInputCellViewModel.swift
//  Finply
//
//  Created by Illia Postoienko on 21.12.2020.
//

import RxSwift

protocol BallanceInputCellViewModelType {
    var currencyTapped: PublishSubject<Void> { get }
    
    var currencyListResult: AnyObserver<CurrencyListCoordinationResult> { get }
}

final class BallanceInputCellViewModel: BallanceInputCellViewModelType {
    
    let currencyTapped = PublishSubject<Void>() // with selected currency
    
    var currencyListResult: AnyObserver<CurrencyListCoordinationResult> { _currencyListResult.asObserver() }
    private let _currencyListResult = PublishSubject<CurrencyListCoordinationResult>()
    
    private let selectedCurrency = BehaviorSubject<Currency>(value: .dollar)
    
    init() {

    }
}
