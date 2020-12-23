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
    
    func addAccountGroup(name: String) -> Single<AccountGroupModelType>
    func updateAccountGroup(_ account: AccountGroupModelType) -> Single<Void>
}

final class AccountsService: AccountsServiceType {
    
    private let repository: FinplyRepositoryType
    private let orderService: OrderServiceType
    
    init(repository: FinplyRepositoryType, orderService: OrderServiceType) {
        self.repository = repository
        self.orderService = orderService
    }
    
    func addAccount(name: String, baseValueInCents: Int, calculatedValueInCents: Int, currency: Currency) -> Single<AccountModelType> {
        repository.getOderedAccounts()
            .map{ [orderService] in orderService.createLastOrder(in: $0) }
            .flatMap { [repository] in
                repository.addAccount(name: name, baseValueInCents: baseValueInCents, calculatedValueInCents: calculatedValueInCents, currency: currency, order: $0)
            }
            .map{ model -> AccountModelType in model }
    }
    
    func updateAccount(_ account: AccountModelType) -> Single<Void> {
        //swiftlint:disable:next force_cast
        repository.updateAccount(account as! AccountModel)
    }
    
    func addAccountGroup(name: String) -> Single<AccountGroupModelType> {
        repository
            .getOderedAccountGroups()
            .map{ [orderService] in orderService.createLastOrder(in: $0) }
            .flatMap { [repository] in
                repository.addAccountGroup(name: name, order: $0)
            }
            .map{ model -> AccountGroupModelType in model }
    }
    
    func updateAccountGroup(_ account: AccountGroupModelType) -> Single<Void> {
        //swiftlint:disable:next force_cast
        repository.updateAccountGroup(account as! AccountGroupModel)
    }
}
