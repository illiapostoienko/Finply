//
//  AccountsListAccountCellViewModel.swift
//  Finply
//
//  Created by Illia Postoienko on 27.11.2020.
//

import RxSwift
import RxCocoa

protocol AccountsListAccountCellViewModelType {
    var accountModel: Observable<AccountDto> { get }
    
    func getActualModel() -> AccountDto
}

final class AccountsListAccountCellViewModel: AccountsListAccountCellViewModelType {
    
    var accountModel: Observable<AccountDto> { _accountModel.asObservable() }
    
    // Locals
    private let _accountModel: BehaviorRelay<AccountDto>
    private let bag = DisposeBag()
    
    init(accountModel: AccountDto) {
        _accountModel = BehaviorRelay<AccountDto>(value: accountModel)
    }
    
    func getActualModel() -> AccountDto {
        _accountModel.value
    }
}
