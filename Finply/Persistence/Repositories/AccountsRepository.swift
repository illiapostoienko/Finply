//
//  AccountsRepository.swift
//  Finply
//
//  Created by Illia Postoienko on 24.12.2020.
//

import RealmSwift
import RxSwift
import RxCocoa

protocol AccountsRepositoryType {
    func getAccounts() -> Single<[AccountDto]>
    func addAccount(name: String, baseValueInCents: Int, calculatedValueInCents: Int, currency: Currency, order: Int) -> Single<AccountDto>
    func updateAccount(_ dto: AccountDto) -> Single<Void>
    func updateAccounts(_ dtos: [AccountDto]) -> Single<Void>
    func deleteAccount(_ dto: AccountDto) -> Single<Void>
    
    func getAccountGroups() -> Single<[AccountGroupDto]>
    func addAccountGroup(name: String, order: Int) -> Single<AccountGroupDto>
    func updateAccountGroup(_ dto: AccountGroupDto) -> Single<Void>
    func updateAccountGroups(_ dtos: [AccountGroupDto]) -> Single<Void>
    func deleteAccountGroup(_ dto: AccountGroupDto) -> Single<Void>
}

final class AccountsRepository: AccountsRepositoryType {
    
    private let accountsRepository = RealmRepository<AccountModel>()
    private let accountGroupsRepository = RealmRepository<AccountGroupModel>()
    
    func getAccounts() -> Single<[AccountDto]> {
        return Single.create { [unowned self] observer in
            do {
                let models = self.accountsRepository.getAll().toArray().map{ AccountDto(accountModel: $0) }
                observer(.success(models))
            } catch {
                observer(.error(error))
            }
            
            return Disposables.create()
        }
    }
    
    func addAccount(name: String, baseValueInCents: Int, calculatedValueInCents: Int, currency: Currency, order: Int) -> Single<AccountDto> {
        return Single.create { [unowned self] observer in
            do {
                let newAccount = AccountModel(name: name, baseValueInCents: baseValueInCents, calculatedValueInCents: calculatedValueInCents, currency: currency, order: order)
                self.accountsRepository.add(models: [newAccount])
                observer(.success(AccountDto(accountModel: newAccount)))
            } catch {
                observer(.error(error))
            }
            
            return Disposables.create()
        }
    }
    
    func updateAccount(_ dto: AccountDto) -> Single<Void> {
        updateAccounts([dto])
    }
    
    func updateAccounts(_ dtos: [AccountDto]) -> Single<Void> {
        return Single.create { [unowned self] observer in
            do {
                self.accountsRepository.update{ dtos.forEach{ $0.applyDbUpdates() }}
                observer(.success(()))
            } catch {
                observer(.error(error))
            }
            
            return Disposables.create()
        }
    }
    
    func deleteAccount(_ dto: AccountDto) -> Single<Void> {
        return Single.create { [unowned self] observer in
            do {
                self.accountsRepository.delete(models: [dto.accountModel])
                observer(.success(()))
            } catch {
                observer(.error(error))
            }
            
            return Disposables.create()
        }
    }
    
    func getAccountGroups() -> Single<[AccountGroupDto]> {
        return Single.create { [unowned self] observer in
            do {
                let models = self.accountGroupsRepository.getAll().toArray().map{ AccountGroupDto(accountGroupModel: $0) }
                observer(.success(models))
            } catch {
                observer(.error(error))
            }
            
            return Disposables.create()
        }
    }
    
    func addAccountGroup(name: String, order: Int) -> Single<AccountGroupDto> {
        return Single.create { [unowned self] observer in
            do {
                let newAccountGroup = AccountGroupModel(name: name, order: order)
                self.accountGroupsRepository.add(models: [newAccountGroup])
                observer(.success(AccountGroupDto(accountGroupModel: newAccountGroup)))
            } catch {
                observer(.error(error))
            }
            
            return Disposables.create()
        }
    }
    
    func updateAccountGroup(_ dto: AccountGroupDto) -> Single<Void> {
        updateAccountGroups([dto])
    }
    
    func updateAccountGroups(_ dtos: [AccountGroupDto]) -> Single<Void> {
        return Single.create { [unowned self] observer in
            do {
                self.accountGroupsRepository.update{ dtos.forEach{ $0.applyDbUpdates() }}
                observer(.success(()))
            } catch {
                observer(.error(error))
            }
            
            return Disposables.create()
        }
    }
    
    func deleteAccountGroup(_ dto: AccountGroupDto) -> Single<Void> {
        return Single.create { [unowned self] observer in
            do {
                self.accountGroupsRepository.delete(models: [dto.accountGroupModel])
                observer(.success(()))
            } catch {
                observer(.error(error))
            }
            
            return Disposables.create()
        }
    }
}
