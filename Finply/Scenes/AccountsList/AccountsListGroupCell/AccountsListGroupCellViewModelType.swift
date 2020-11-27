//
//  AccountsListGroupCellViewModelType.swift
//  Finply
//
//  Created by Illia Postoienko on 27.11.2020.
//

import RxSwift
import RxCocoa

protocol AccountsListGroupCellViewModelType {
    var accountGroupModel: FPAccountGroup { get }
}

final class AccountsListGroupCellViewModel: AccountsListGroupCellViewModelType {
    
    let accountGroupModel: FPAccountGroup
    
    init(accountGroupModel: FPAccountGroup) {
        self.accountGroupModel = accountGroupModel
    }
}
