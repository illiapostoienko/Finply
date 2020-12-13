//
//  AccountsListAccountCellViewModel.swift
//  Finply
//
//  Created by Illia Postoienko on 27.11.2020.
//

import RxSwift
import RxCocoa
import Foundation

protocol AccountsListAccountCellViewModelType {
    var accountModel: AccountModelType { get }
}

final class AccountsListAccountCellViewModel: AccountsListAccountCellViewModelType {
    
    let accountModel: AccountModelType
    
    init(accountModel: AccountModelType = AccountModel(name: "Some name", baseValueInCents: 0, currency: .afghani, order: 0)) {
        self.accountModel = accountModel
    }
}
