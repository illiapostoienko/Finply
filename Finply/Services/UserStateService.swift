//
//  UserStateService.swift
//  Finply
//
//  Created by Illia Postoienko on 29.11.2020.
//

import Foundation

protocol UserStateServiceType {
    func getCurrentOpenedAccount() -> AccountModelType
}

final class UserStateService: UserStateServiceType {
    
    func getCurrentOpenedAccount() -> AccountModelType {
        return AccountModel(name: "Some name", baseValueInCents: 0, currency: .afghani, order: 0)
    }
}
