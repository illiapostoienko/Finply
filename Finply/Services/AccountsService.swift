//
//  AccountsService.swift
//  Finply
//
//  Created by Illia Postoienko on 23.12.2020.
//

import Foundation
import RxSwift

protocol AccountsServiceType {
    func addAccount(name: String, baseValueInCents: Int, calculatedValueInCents: Int, currency: Currency) -> Single<AccountModelType>
    func updateAccount(_ account: AccountModelType) -> Single<Void>
    func getOrderedAccounts() -> Single<[AccountModelType]>
    func deleteAccount(_ account: AccountModelType) -> Single<Void>
    func changeAccountOrder(fromIndex: Int, toIndex: Int) -> Single<Void>
    
    func addAccountGroup(name: String) -> Single<AccountGroupModelType>
    func updateAccountGroup(_ accountGroup: AccountGroupModelType) -> Single<Void>
    func getOrderedAccountGroups() -> Single<[AccountGroupModelType]>
    func deleteAccountGroup(_ accountGroup: AccountGroupModelType) -> Single<Void>
    func changeAccountGroupOrder(fromIndex: Int, toIndex: Int) -> Single<Void>
}

//swiftlint:disable force_cast
final class AccountsService: AccountsServiceType {
    
    private let repository: FinplyRepositoryType
    private let orderService: OrderServiceType
    
    deinit {
        print("deinit AccountsService")
    }
    
    init(repository: FinplyRepositoryType, orderService: OrderServiceType) {
        self.repository = repository
        self.orderService = orderService
    }
    
    // MARK: - Accounts
    func addAccount(name: String, baseValueInCents: Int, calculatedValueInCents: Int, currency: Currency) -> Single<AccountModelType> {
        repository.getAccounts()
            .map{ [orderService] in orderService.createLastOrder(in: $0) }
            .flatMap { [repository] in
                repository.addAccount(name: name, baseValueInCents: baseValueInCents,
                                      calculatedValueInCents: calculatedValueInCents,
                                      currency: currency, order: $0)
            }
            .map{ model -> AccountModelType in model }
    }
    
    func updateAccount(_ account: AccountModelType) -> Single<Void> {
        repository.updateAccount(account as! AccountModel)
    }
    
    func getOrderedAccounts() -> Single<[AccountModelType]> {
        repository.getAccounts()
            .map{ $0.map{ $0 as AccountModelType }}
    }
    
    func deleteAccount(_ account: AccountModelType) -> Single<Void> {
        repository.getAccounts()
            .map{ [orderService] in orderService.deleteOrder(at: account.order, in: $0) }
            .flatMap{ [repository] in repository.deleteAccount(account as! AccountModel) }
    }
    
    func changeAccountOrder(fromIndex: Int, toIndex: Int) -> Single<Void> {
        repository.getAccounts()
            .map{ [orderService] in orderService.changeOrder(from: fromIndex, to: toIndex, in: $0) }
    }
    
    // MARK: - Account Groups
    func addAccountGroup(name: String) -> Single<AccountGroupModelType> {
        repository
            .getAccountGroups()
            .map{ [orderService] in orderService.createLastOrder(in: $0) }
            .flatMap { [repository] in repository.addAccountGroup(name: name, order: $0) }
            .map{ model -> AccountGroupModelType in model }
    }
    
    func updateAccountGroup(_ accountGroup: AccountGroupModelType) -> Single<Void> {
        repository.updateAccountGroup(accountGroup as! AccountGroupModel)
    }
    
    func getOrderedAccountGroups() -> Single<[AccountGroupModelType]> {
        repository.getAccountGroups()
            .map{ $0.map{ $0 as AccountGroupModelType }}
    }
    
    func deleteAccountGroup(_ accountGroup: AccountGroupModelType) -> Single<Void> {
        repository.getAccountGroups()
            .map{ [orderService] in orderService.deleteOrder(at: accountGroup.order, in: $0) }
            .flatMap{ [repository] in repository.deleteAccountGroup(accountGroup as! AccountGroupModel) }
    }
    
    func changeAccountGroupOrder(fromIndex: Int, toIndex: Int) -> Single<Void> {
        repository.getAccountGroups()
            .map{ [orderService] in orderService.changeOrder(from: fromIndex, to: toIndex, in: $0) }
    }
}
