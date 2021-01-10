//
//  AccountsListGroupCellViewModel.swift
//  Finply
//
//  Created by Illia Postoienko on 27.11.2020.
//

import RxSwift
import RxCocoa

protocol AccountsListGroupCellViewModelType {
    var accountGroup: Observable<AccountGroupDto> { get }
    
    func getActualModel() -> AccountGroupDto
}

final class AccountsListGroupCellViewModel: AccountsListGroupCellViewModelType {
    
    var accountGroup: Observable<AccountGroupDto> { _accountGroup.asObservable() }
    
    // Locals
    private let _accountGroup: BehaviorRelay<AccountGroupDto>
    private let bag = DisposeBag()
    
    init(accountGroup: AccountGroupDto) {
        _accountGroup = BehaviorRelay<AccountGroupDto>(value: accountGroup)
    }
    
    func getActualModel() -> AccountGroupDto {
        _accountGroup.value
    }
}
