//
//  AccountsListAccountCellViewModel.swift
//  Finply
//
//  Created by Illia Postoienko on 27.11.2020.
//

import RxSwift
import RxCocoa

protocol AccountsListAccountCellViewModelType {
    var account: Observable<AccountDto> { get }
    
    func getActualModel() -> AccountDto
}

final class AccountsListAccountCellViewModel: AccountsListAccountCellViewModelType {
    
    var account: Observable<AccountDto> { _account.asObservable() }
    
    // Locals
    private let _account: BehaviorRelay<AccountDto>
    private let bag = DisposeBag()
    
    init(account: AccountDto) {
        _account = BehaviorRelay<AccountDto>(value: account)
    }
    
    func getActualModel() -> AccountDto {
        _account.value
    }
}
