//
//  BallanceInputCellViewModel.swift
//  Finply
//
//  Created by Illia Postoienko on 21.12.2020.
//

import Foundation
import RxSwift

protocol BallanceInputCellViewModelType {
    var currencyTapped: PublishSubject<Void> { get }
    
    // Input
    var inputStringValue: AnyObserver<String> { get }
    var currencyListResult: AnyObserver<CurrencyListCoordinationResult> { get }
    
    // Output
    var inputValueInCents: Observable<Int?> { get }
    var currentStringValue: Observable<String> { get }
    var selectedCurrency: Observable<Currency> { get }
}

final class BallanceInputCellViewModel: BallanceInputCellViewModelType {
    
    let currencyTapped = PublishSubject<Void>() // with selected currency
    
    var inputStringValue: AnyObserver<String> { _inputStringValue.asObserver() }
    var currencyListResult: AnyObserver<CurrencyListCoordinationResult> { _currencyListResult.asObserver() }
    
    private let _inputStringValue = PublishSubject<String>()
    private let _currencyListResult = PublishSubject<CurrencyListCoordinationResult>()
    
    let inputValueInCents: Observable<Int?>
    var currentStringValue: Observable<String> { _stringValue }
    var selectedCurrency: Observable<Currency> { _selectedCurrency }
    
    private let _selectedCurrency = BehaviorSubject<Currency>(value: .dollar)
    private let _stringValue = BehaviorSubject<String>(value: "")
    private let bag = DisposeBag()
    
    init() {
        inputValueInCents = _stringValue
            .map{ stringValue in Double(stringValue).flatMap{ round($0*100) }.flatMap{ Int($0) }}
        
        _inputStringValue
            .bind(to: _stringValue)
            .disposed(by: bag)
        
        // _currencyListResult -> set currency if needed
    }
}
