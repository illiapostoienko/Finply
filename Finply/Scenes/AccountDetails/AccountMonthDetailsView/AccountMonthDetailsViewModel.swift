//
//  AccountMonthDetailsViewModel.swift
//  Finply
//
//  Created by Illia Postoienko on 06.11.2020.
//

import Foundation
import RxSwift
import RxCocoa

protocol AccountMonthDetailsViewModelType {
    var itemSelected: PublishSubject<Int> { get }
}

final class AccountMonthDetailsViewModel: AccountMonthDetailsViewModelType {
    
    let itemSelected = PublishSubject<Int>()
    
    let bag = DisposeBag()
    
    init() {
        itemSelected
            .subscribe(onNext: {
                let hb = $0
            })
            .disposed(by: bag)
    }
}
