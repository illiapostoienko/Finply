//
//  FinplyRepository.swift
//  Finply
//
//  Created by Illia Postoienko on 23.12.2020.
//

import RealmSwift
import RxSwift
import RxCocoa

protocol FinplyRepositoryType {
    func getAccounts() -> Single<[AccountModel]>
    func addAccount(name: String, baseValueInCents: Int, calculatedValueInCents: Int, currency: Currency, order: Int) -> Single<AccountModel>
    func updateAccount(_ accountModel: AccountModel) -> Single<Void>
    func updateAccounts(_ accountModels: [AccountModel]) -> Single<Void>
    func deleteAccount(_ accountModel: AccountModel) -> Single<Void>
    
    func getAccountGroups() -> Single<[AccountGroupModel]>
    func addAccountGroup(name: String, order: Int) -> Single<AccountGroupModel>
    func updateAccountGroup(_ accountGroupModel: AccountGroupModel) -> Single<Void>
    func updateAccountGroups(_ accountGroupModels: [AccountGroupModel]) -> Single<Void>
    func deleteAccountGroup(_ accountGroupModel: AccountGroupModel) -> Single<Void>
}

final class FinplyRepository: FinplyRepositoryType {
    
    private let accountsRepository = RealmRepository<AccountModel>()
    private let accountGroupsRepository = RealmRepository<AccountGroupModel>()
    private let operationSectionsRepository = RealmRepository<OperationSectionModel>()
    private let operationsRepository = RealmRepository<OperationModel>()
    private let categoriesRepository = RealmRepository<CategoryModel>()
    
    deinit {
        print("deinit FinplyRepository")
    }
    
    func getAccounts() -> Single<[AccountModel]> {
        return Single.create { [unowned self] observer in
            do {
                let models = self.accountsRepository
                    .getAll()
                    .map{ [accountsRepository] account -> AccountModel in
                        account.repositoryDelegate = accountsRepository
                        return account
                    }
                observer(.success(models))
            } catch {
                observer(.error(error))
            }
            
            return Disposables.create()
        }
    }
    
    func addAccount(name: String, baseValueInCents: Int, calculatedValueInCents: Int, currency: Currency, order: Int) -> Single<AccountModel> {
        return Single.create { [unowned self] observer in
            do {
                let newAccount = AccountModel(name: name, baseValueInCents: baseValueInCents, calculatedValueInCents: calculatedValueInCents, currency: currency, order: order)
                self.accountsRepository.addOrUpdate(models: [newAccount])
                observer(.success(newAccount))
            } catch {
                observer(.error(error))
            }
            
            return Disposables.create()
        }
    }
    
    func updateAccount(_ accountModel: AccountModel) -> Single<Void> {
        updateAccounts([accountModel])
    }
    
    func updateAccounts(_ accountModels: [AccountModel]) -> Single<Void> {
        return Single.create { [unowned self] observer in
            do {
                self.accountsRepository.addOrUpdate(models: accountModels)
                observer(.success(()))
            } catch {
                observer(.error(error))
            }
            
            return Disposables.create()
        }
    }
    
    func deleteAccount(_ accountModel: AccountModel) -> Single<Void> {
        return Single.create { [unowned self] observer in
            do {
                self.accountsRepository.delete(models: [accountModel])
                observer(.success(()))
            } catch {
                observer(.error(error))
            }
            
            return Disposables.create()
        }
    }
    
    func getAccountGroups() -> Single<[AccountGroupModel]> {
        return Single.create { [unowned self] observer in
            do {
                let models = self.accountGroupsRepository
                    .getAll()
                    .map{ [accountsRepository] accountGroup -> AccountGroupModel in
                        accountGroup.repositoryDelegate = accountsRepository
                        return accountGroup
                    }
                observer(.success(models))
            } catch {
                observer(.error(error))
            }
            
            return Disposables.create()
        }
    }
    
    func addAccountGroup(name: String, order: Int) -> Single<AccountGroupModel> {
        return Single.create { [unowned self] observer in
            do {
                let newAccountGroup = AccountGroupModel(name: name, order: order)
                self.accountGroupsRepository.addOrUpdate(models: [newAccountGroup])
                observer(.success(newAccountGroup))
            } catch {
                observer(.error(error))
            }
            
            return Disposables.create()
        }
    }
    
    func updateAccountGroup(_ accountGroupModel: AccountGroupModel) -> Single<Void> {
        updateAccountGroups([accountGroupModel])
    }
    
    func updateAccountGroups(_ accountGroupModels: [AccountGroupModel]) -> Single<Void> {
        return Single.create { [unowned self] observer in
            do {
                self.accountGroupsRepository.addOrUpdate(models: accountGroupModels)
                observer(.success(()))
            } catch {
                observer(.error(error))
            }
            
            return Disposables.create()
        }
    }
    
    func deleteAccountGroup(_ accountGroupModel: AccountGroupModel) -> Single<Void> {
        return Single.create { [unowned self] observer in
            do {
                self.accountGroupsRepository.delete(models: [accountGroupModel])
                observer(.success(()))
            } catch {
                observer(.error(error))
            }
            
            return Disposables.create()
        }
    }
}
