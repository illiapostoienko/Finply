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
    
    let repository: FinplyRepositoryType
    
    init(repository: FinplyRepositoryType) {
        self.repository = repository
    }
    
    func getCurrentOpenedAccount() -> AccountModelType {
        return AccountModel(name: "Some name", baseValueInCents: 0, calculatedValueInCents: 0, currency: .afghani, order: 0)
    }
}
