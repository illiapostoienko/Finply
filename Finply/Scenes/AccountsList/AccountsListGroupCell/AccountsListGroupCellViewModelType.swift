//
//  AccountsListGroupCellViewModelType.swift
//  Finply
//
//  Created by Illia Postoienko on 27.11.2020.
//

import RxSwift
import RxCocoa

protocol AccountsListGroupCellViewModelType {
    var accountGroupModel: AccountGroupModelType { get }
}

final class AccountsListGroupCellViewModel: AccountsListGroupCellViewModelType {
    
    let accountGroupModel: AccountGroupModelType
    
    init(accountGroupModel: AccountGroupModelType) {
        self.accountGroupModel = accountGroupModel
    }
}
