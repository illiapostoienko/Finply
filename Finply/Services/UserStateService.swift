//
//  UserStateService.swift
//  Finply
//
//  Created by Illia Postoienko on 29.11.2020.
//

import Foundation
import RxSwift

protocol UserStateServiceType {
    // func getCurrentOpenedAccount() -> Single<AccountDto>
}

final class UserStateService: UserStateServiceType {
    
    let repository: AccountsRepositoryType
    
    init(repository: AccountsRepositoryType) {
        self.repository = repository
    }
    
//    func getCurrentOpenedAccount() -> Single<AccountDto> {
//
//    }
}
