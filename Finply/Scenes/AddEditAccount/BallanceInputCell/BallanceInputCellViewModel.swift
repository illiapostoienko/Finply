//
//  BallanceInputCellViewModel.swift
//  Finply
//
//  Created by Illia Postoienko on 21.12.2020.
//

import Foundation
import RxSwift
import RxCocoa

protocol BallanceInputCellViewModelType {
    
    // Input
    var currencyTapped: PublishSubject<Void> { get }
    var currencyListResult: AnyObserver<CurrencyListCoordinationResult> { get }
    
    // Output
    var selectedCurrency: Observable<Currency> { get }
    var ballanceInCents: Observable<Int?> { get }
    
    // BiBinded to Cell
    var ballanceString: BehaviorRelay<String> { get }
    
    func setCurrentBallance(_ ballanceInCents: Int)
    func setCurrentCurrency(_ currency: Currency)
}

final class BallanceInputCellViewModel: BallanceInputCellViewModelType {
    
    // Input
    let currencyTapped = PublishSubject<Void>() // with selected currency
    var currencyListResult: AnyObserver<CurrencyListCoordinationResult> { _currencyListResult.asObserver() }
    
    // Output
    var selectedCurrency: Observable<Currency> { _selectedCurrency.asObservable() }
    var ballanceInCents: Observable<Int?> { _ballanceInCents.asObservable() }
    
    // BiBinded to Cell
    let ballanceString: BehaviorRelay<String> = BehaviorRelay<String>(value: "")
    
    private let _inputStringValue = PublishSubject<String>()
    private let _currencyListResult = PublishSubject<CurrencyListCoordinationResult>()
    
    private let numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
        numberFormatter.minimumIntegerDigits = 1
        
        return numberFormatter
    }()
    
    private let _ballanceInCents = BehaviorRelay<Int?>(value: nil)
    private let _selectedCurrency = BehaviorRelay<Currency>(value: .dollar)
    private let bag = DisposeBag()
    
    init() {
        ballanceString
            .map{ [numberFormatter] stringValue in
                numberFormatter.number(from: stringValue)
                    .flatMap{ Double(exactly: $0) }
                    .flatMap{ round($0*100) }
                    .flatMap{ Int($0) }
            }
            .bind(to: _ballanceInCents)
            .disposed(by: bag)
        
        _currencyListResult
            .map{ result -> Currency? in
                switch result {
                case .selectedCurrency(let currency): return currency
                default: return nil
                }
            }
            .unwrap()
            .bind(to: _selectedCurrency)
            .disposed(by: bag)
    }
    
    func setCurrentBallance(_ ballanceInCents: Int) {
        numberFormatter.string(from: Double(ballanceInCents)/Double(100)).map{ ballanceString.accept($0) }
    }
    
    func setCurrentCurrency(_ currency: Currency) {
        _selectedCurrency.accept(currency)
    }
}
