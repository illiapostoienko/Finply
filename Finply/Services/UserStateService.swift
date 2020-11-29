//
//  UserStateService.swift
//  Finply
//
//  Created by Illia Postoienko on 29.11.2020.
//

import Foundation

protocol UserStateServiceType {
    func getCurrentOpenedAccount() -> FPAccount
}

final class UserStateService: UserStateServiceType {
    
    func getCurrentOpenedAccount() -> FPAccount {
        return FPAccount(id: UUID(), name: "Some name", baseValue: 0.0, calculatedValue: 0.0, currency: "UAH", order: 0)
    }
}
