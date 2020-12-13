//
//  AccountsRepository.swift
//  Finply
//
//  Created by Illia Postoienko on 12.12.2020.
//

import Foundation
import RealmSwift

protocol AccountsRepositoryType {
    
}

final class AccountsRepository: RealmRepository<AccountModel>, AccountsRepositoryType {
    
    lazy var sortedAccounts: Results<AccountModel> = { self.getAllSorted(orderKey: "order", ascending: true) }()
    
}
