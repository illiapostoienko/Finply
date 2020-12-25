//
//  AccountsService.swift
//  Finply
//
//  Created by Illia Postoienko on 23.12.2020.
//

import Foundation
import RxSwift

protocol AccountsServiceType {
    func addAccount(name: String, baseValueInCents: Int, calculatedValueInCents: Int, currency: Currency) -> Single<AccountDto>
    func updateAccount(_ account: AccountDto) -> Single<Void>
    func getAllAccounts() -> Single<[AccountDto]>
    func deleteAccount(_ account: AccountDto) -> Single<Void>
    func changeAccountOrder(fromIndex: Int, toIndex: Int) -> Single<Void>
    
    func addAccountGroup(name: String) -> Single<AccountGroupDto>
    func updateAccountGroup(_ accountGroup: AccountGroupDto) -> Single<Void>
    func getAllAccountGroups() -> Single<[AccountGroupDto]>
    func deleteAccountGroup(_ accountGroup: AccountGroupDto) -> Single<Void>
    func changeAccountGroupOrder(fromIndex: Int, toIndex: Int) -> Single<Void>
}

final class AccountsService: AccountsServiceType {
    
    private let repository: AccountsRepositoryType
    private let orderService: OrderServiceType
    
    init(repository: AccountsRepositoryType, orderService: OrderServiceType) {
        self.repository = repository
        self.orderService = orderService
    }
    
    // MARK: - Accounts
    func addAccount(name: String, baseValueInCents: Int, calculatedValueInCents: Int, currency: Currency) -> Single<AccountDto> {
        repository.getAccounts()
            .map{ [orderService] in orderService.createLastOrder(in: $0) }
            .flatMap { [repository] in
                repository.addAccount(name: name, baseValueInCents: baseValueInCents,
                                      calculatedValueInCents: calculatedValueInCents,
                                      currency: currency, order: $0)
            }
    }
    
    func updateAccount(_ account: AccountDto) -> Single<Void> {
        repository.updateAccount(account)
    }
    
    func getAllAccounts() -> Single<[AccountDto]> {
        repository.getAccounts()
    }
    
    func deleteAccount(_ account: AccountDto) -> Single<Void> {
        repository.getAccounts()
            .map{ [orderService] in orderService.deleteOrder(at: account.order, in: $0) }
            .flatMap{ [repository] in repository.updateAccounts($0) }
            .flatMap{ [repository] in repository.deleteAccount(account) }
    }
    
    func changeAccountOrder(fromIndex: Int, toIndex: Int) -> Single<Void> {
        repository.getAccounts()
            .map{ [orderService] in orderService.changeOrder(from: fromIndex, to: toIndex, in: $0) }
            .flatMap{ [repository] in repository.updateAccounts($0) }
    }
    
    // MARK: - Account Groups
    func addAccountGroup(name: String) -> Single<AccountGroupDto> {
        repository
            .getAccountGroups()
            .map{ [orderService] in orderService.createLastOrder(in: $0) }
            .flatMap { [repository] in repository.addAccountGroup(name: name, order: $0) }
    }
    
    func updateAccountGroup(_ accountGroup: AccountGroupDto) -> Single<Void> {
        repository.updateAccountGroup(accountGroup)
    }
    
    func getAllAccountGroups() -> Single<[AccountGroupDto]> {
        repository.getAccountGroups()
    }
    
    func deleteAccountGroup(_ accountGroup: AccountGroupDto) -> Single<Void> {
        repository.getAccountGroups()
            .map{ [orderService] in orderService.deleteOrder(at: accountGroup.order, in: $0) }
            .flatMap{ [repository] in repository.updateAccountGroups($0) }
            .flatMap{ [repository] in repository.deleteAccountGroup(accountGroup) }
    }
    
    func changeAccountGroupOrder(fromIndex: Int, toIndex: Int) -> Single<Void> {
        repository.getAccountGroups()
            .map{ [orderService] in orderService.changeOrder(from: fromIndex, to: toIndex, in: $0) }
            .flatMap{ [repository] in repository.updateAccountGroups($0) }
    }
}
