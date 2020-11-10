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
    var reportDetailsTap: PublishSubject<Void> { get }
}

final class AccountMonthDetailsViewModel: AccountMonthDetailsViewModelType {
    
    let reportDetailsTap = PublishSubject<Void>()
    
    let bag = DisposeBag()
    
    init() {
        
    }
}
