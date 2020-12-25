//
//  AccountsListViewModel.swift
//  Finply
//
//  Created by Illia Postoienko on 23.10.2020.
//

import RxSwift
import RxCocoa
import RxDataSources
import Foundation
import RxSwiftExt

protocol AccountsListViewModelInput {
    var backButtonTap: AnyObserver<Void> { get }
    var addButtonTap: AnyObserver<Void> { get }
    var tabButtonTap: AnyObserver<AccountsListTab> { get }
    var rowSelected: AnyObserver<Int> { get }
    var changeOrder: AnyObserver<(fromIndex: Int, toIndex: Int)> { get }
    var reload: AnyObserver<Void> { get }
    
    var addEditAccountResult: AnyObserver<AddEditAccountCoordinationResult> { get }
}

protocol AccountsListViewModelOutput {
    var dataSource: Observable<[AccountsListTableItem]> { get }
}

protocol AccountsListViewModelCoordination {
    var completeCoordinationResult: Observable<AccountsListCoordinationResult> { get }
    var openAddEditAccount: Observable<AddEditAccountSceneState> { get }
}

protocol AccountsListViewModelType {
    var input: AccountsListViewModelInput { get }
    var output: AccountsListViewModelOutput { get }
    var coordination: AccountsListViewModelCoordination { get }
}

enum AccountsListTab {
    case accounts
    case groups
}

final class AccountsListViewModel: AccountsListViewModelType, AccountsListViewModelOutput, AccountsListViewModelInput, AccountsListViewModelCoordination {
    
    var input: AccountsListViewModelInput { return self }
    var output: AccountsListViewModelOutput { return self }
    var coordination: AccountsListViewModelCoordination { return self }
    
    // Output
    var dataSource: Observable<[AccountsListTableItem]> { _dataSource.asObservable() }
    
    private let _dataSource = BehaviorRelay<[AccountsListTableItem]>(value: [])
    
    // Input
    var backButtonTap: AnyObserver<Void> { _backButtonTap.asObserver() }
    var addButtonTap: AnyObserver<Void> { _addButtonTap.asObserver() }
    var tabButtonTap: AnyObserver<AccountsListTab> { _tabButtonTap.asObserver() }
    var rowSelected: AnyObserver<Int> { _rowSelected.asObserver() }
    var changeOrder: AnyObserver<(fromIndex: Int, toIndex: Int)> { _changeOrder.asObserver() }
    var addEditAccountResult: AnyObserver<AddEditAccountCoordinationResult> { _addEditAccountResult.asObserver() }
    var reload: AnyObserver<Void> { _reload.asObserver() }
    
    private let _backButtonTap = PublishSubject<Void>()
    private let _addButtonTap = PublishSubject<Void>()
    private let _tabButtonTap = PublishSubject<AccountsListTab>()
    private let _rowSelected = PublishSubject<Int>()
    private let _changeOrder = PublishSubject<(fromIndex: Int, toIndex: Int)>()
    private let _addEditAccountResult = PublishSubject<AddEditAccountCoordinationResult>()
    private let _reload = PublishSubject<Void>()
    
    // Coordination
    var completeCoordinationResult: Observable<AccountsListCoordinationResult> { _completeCoordinationResult }
    var openAddEditAccount: Observable<AddEditAccountSceneState> { _openAddEditAccount }
    
    private let _completeCoordinationResult = PublishSubject<AccountsListCoordinationResult>()
    private let _openAddEditAccount = PublishSubject<AddEditAccountSceneState>()
    
    // Locals
    private let _currentTab = BehaviorRelay<AccountsListTab>(value: .accounts)
    private let loadedAccounts = BehaviorRelay<[AccountDto]>(value: [])
    private let loadedAccountGroups = BehaviorRelay<[AccountGroupDto]>(value: [])
    private let _deleteAccount = PublishSubject<AccountDto>()
    private let _deleteAccountGroup = PublishSubject<AccountGroupDto>()
    
    private var accountItems: Observable<[AccountsListTableItem]> {
        loadedAccounts.map{ [unowned self] accounts in
            var accounts = accounts
            accounts.sort(by: { $0.order < $1.order })
            
            return accounts.map {
                let vm = AccountsListAccountCellViewModel(accountModel: $0)
                
                vm.editAccount
                    .map{ AddEditAccountSceneState.editAccount($0) }
                    .bind(to: self._openAddEditAccount)
                    .disposed(by: self.bag)
                
                vm.deleteAccount
                    .bind(to: self._deleteAccount)
                    .disposed(by: self.bag)
                
                return .account(viewModel: vm)
            }
        }
    }
    
    private var groupItems: Observable<[AccountsListTableItem]> {
        loadedAccountGroups.map{ [unowned self] groups in
            var groups = groups
            groups.sort(by: { $0.order < $1.order })
            
            return groups.map {
                let vm = AccountsListGroupCellViewModel(accountGroupModel: $0)
                
                vm.editAccountGroup
                    .map{ AddEditAccountSceneState.editAccountGroup($0) }
                    .bind(to: self._openAddEditAccount)
                    .disposed(by: self.bag)
                
                vm.deleteAccountGroup
                    .bind(to: self._deleteAccountGroup)
                    .disposed(by: self.bag)
                
                return .accountGroup(viewModel: vm)
            }
        }
    }
    
    //Services
    private let accountsService: AccountsServiceType
    private let bag = DisposeBag()
    
    init(accountsService: AccountsServiceType) {
        self.accountsService = accountsService
        
        _tabButtonTap
            .bind(to: _currentTab)
            .disposed(by: bag)
        
        let latestState = Observable.combineLatest(_currentTab, loadedAccounts, loadedAccountGroups).map{ (tab: $0, accounts: $1, groups: $2) }
        let selectedRowWithLatestData = _rowSelected.withLatestFrom(latestState) { ($0, $1) }
        
        _backButtonTap
            .map{ .back }
            .bind(to: _completeCoordinationResult)
            .disposed(by: bag)
        
        selectedRowWithLatestData
            .filter{ $1.tab == .accounts }
            .map{ $1.accounts[safe: $0] }
            .unwrap()
            .map{ .accountSelected(model: $0) }
            .bind(to: _completeCoordinationResult)
            .disposed(by: bag)
        
        selectedRowWithLatestData
            .filter{ $1.tab == .accounts }
            .map{ $1.groups[safe: $0] }
            .unwrap()
            .map{ .accountGroupSelected(model: $0) }
            .bind(to: _completeCoordinationResult)
            .disposed(by: bag)

        _addButtonTap
            .withLatestFrom(_currentTab)
            .map{
                switch $0 {
                case .accounts: return .addAccount
                case .groups: return .addAccountGroup
                }
            }
            .bind(to: _openAddEditAccount)
            .disposed(by: bag)
        
        _addEditAccountResult
            .withLatestFrom(latestState) { result, data -> [AccountDto]? in
                var accounts = data.accounts
                switch result {
                case .accountAdded(let accountDto): accounts.append(accountDto)
                //case .accountEdited(let accountDto): return nil
                default: return nil
                }
                return accounts
            }
            .unwrap()
            .bind(to: loadedAccounts)
            .disposed(by: bag)
        
        _addEditAccountResult
            .withLatestFrom(latestState) { result, data -> [AccountGroupDto]? in
                var accountGroups = data.groups
                switch result {
                case .accountGroupAdded(let accountGroupDto): accountGroups.append(accountGroupDto)
                //case .accountGroupEdited(let accountGroupDto): return nil
                default: return nil
                }
                return accountGroups
            }
            .unwrap()
            .bind(to: loadedAccountGroups)
            .disposed(by: bag)
        
        _changeOrder.withLatestFrom(latestState) { orderSet, dataSet in
            
        }
        
        _deleteAccount
            .withLatestFrom(loadedAccounts) { [unowned self] accountToDelete, accounts in
                var accounts = accounts
                accounts.removeAll(where: { $0 === accountToDelete })
                self.loadedAccounts.accept(accounts)
                return accountToDelete
            }
            .flatMap{ [unowned self] in self.accountsService.deleteAccount($0) }
            .subscribe()
            .disposed(by: bag)
        
        _deleteAccountGroup
            .withLatestFrom(loadedAccountGroups) { [unowned self] accountGroupToDelete, accountGroups in
                var accountGroups = accountGroups
                accountGroups.removeAll(where: { $0 === accountGroupToDelete })
                self.loadedAccountGroups.accept(accountGroups)
                return accountGroupToDelete
            }
            .flatMap{ [unowned self] in self.accountsService.deleteAccountGroup($0) }
            .subscribe()
            .disposed(by: bag)
        
        Observable.combineLatest(_currentTab, accountItems, groupItems)
            .map{ tab, accounts, groups -> [AccountsListTableItem] in
                switch tab {
                case .accounts: return accounts
                case .groups: return groups
                }
            }
            .bind(to: _dataSource)
            .disposed(by: bag)
        
        _reload
            .flatMap{ [unowned self] in self.accountsService.getAllAccounts() }
            .bind(to: loadedAccounts)
            .disposed(by: bag)
        
        _reload
            .flatMap{ [unowned self] in self.accountsService.getAllAccountGroups() }
            .bind(to: loadedAccountGroups)
            .disposed(by: bag)
    }
}

enum AccountsListTableItem: IdentifiableType, Equatable {
    case account(viewModel: AccountsListAccountCellViewModelType)
    case accountGroup(viewModel: AccountsListGroupCellViewModelType)
    
    var identity: String {
        switch self {
        case .account(let viewModel): return viewModel.getAccountId()
        case .accountGroup(let viewModel): return viewModel.getAccountGroupId()
        }
    }
    
    static func == (lhs: AccountsListTableItem, rhs: AccountsListTableItem) -> Bool {
        return lhs.identity == rhs.identity
    }
}
