//
//  AccountsListGroupCellViewModel.swift
//  Finply
//
//  Created by Illia Postoienko on 27.11.2020.
//

import RxSwift
import RxCocoa

protocol AccountsListGroupCellViewModelType {
    var accountGroupModel: Observable<AccountGroupDto> { get }
    
    func getActualModel() -> AccountGroupDto
}

final class AccountsListGroupCellViewModel: AccountsListGroupCellViewModelType {
    
    var accountGroupModel: Observable<AccountGroupDto> { _accountGroupModel.asObservable() }
    
    // Locals
    private let _accountGroupModel: BehaviorRelay<AccountGroupDto>
    private let bag = DisposeBag()
    
    init(accountGroupModel: AccountGroupDto) {
        _accountGroupModel = BehaviorRelay<AccountGroupDto>(value: accountGroupModel)
    }
    
    func getActualModel() -> AccountGroupDto {
        _accountGroupModel.value
    }
}
