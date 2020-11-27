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
    var accountModel: FPAccount { get }
}

final class AccountsListAccountCellViewModel: AccountsListAccountCellViewModelType {
    
    let accountModel: FPAccount
    
    init(accountModel: FPAccount = FPAccount(id: UUID(), name: "", baseValue: 0.0, calculatedValue: 0.0, currency: "UAH", order: 0)) {
        self.accountModel = accountModel
    }
}
