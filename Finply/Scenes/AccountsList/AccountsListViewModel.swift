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
    var rowEditTap: AnyObserver<Int> { get }
    var rowDeleteTap: AnyObserver<Int> { get }
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
    var rowEditTap: AnyObserver<Int> { _rowEditTap.asObserver() }
    var rowDeleteTap: AnyObserver<Int> { _rowDeleteTap.asObserver() }
    var changeOrder: AnyObserver<(fromIndex: Int, toIndex: Int)> { _changeOrder.asObserver() }
    var addEditAccountResult: AnyObserver<AddEditAccountCoordinationResult> { _addEditAccountResult.asObserver() }
    var reload: AnyObserver<Void> { _reload.asObserver() }
    
    private let _backButtonTap = PublishSubject<Void>()
    private let _addButtonTap = PublishSubject<Void>()
    private let _tabButtonTap = PublishSubject<AccountsListTab>()
    private let _rowSelected = PublishSubject<Int>()
    private let _rowEditTap = PublishSubject<Int>()
    private let _rowDeleteTap = PublishSubject<Int>()
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
    
    private var accountItems: Observable<[AccountsListTableItem]> {
        loadedAccounts.map{ accounts in
            var accounts = accounts
            accounts.sort(by: { $0.order < $1.order })
            return accounts.map { .account(viewModel: AccountsListAccountCellViewModel(accountModel: $0)) }
        }
    }
    
    private var groupItems: Observable<[AccountsListTableItem]> {
        loadedAccountGroups.map{ groups in
            var groups = groups
            groups.sort(by: { $0.order < $1.order })
            return groups.map { .accountGroup(viewModel: AccountsListGroupCellViewModel(accountGroupModel: $0)) }
        }
    }
    
    //Services
    private let accountsService: AccountsServiceType
    private let orderService: OrderServiceType
    private let bag = DisposeBag()
    
    init(accountsService: AccountsServiceType, orderService: OrderServiceType) {
        self.accountsService = accountsService
        self.orderService = orderService
        
        _tabButtonTap
            .bind(to: _currentTab)
            .disposed(by: bag)
        
        let latestState = Observable.combineLatest(_currentTab, loadedAccounts, loadedAccountGroups).map{ (tab: $0, accounts: $1, groups: $2) } // TODO: Check about producing a lot of events
        let selectedRowWithLatestData = _rowSelected.withLatestFrom(latestState) { ($0, $1) }
        
        // Return Coordination
        _backButtonTap
            .map{ .back }
            .bind(to: _completeCoordinationResult)
            .disposed(by: bag)
        
        selectedRowWithLatestData
            .filter{ $1.tab == .accounts }
            .map{ row, state in state.accounts.first { $0.order == row }}
            .unwrap()
            .map{ .accountSelected(model: $0) }
            .bind(to: _completeCoordinationResult)
            .disposed(by: bag)
        
        selectedRowWithLatestData
            .filter{ $1.tab == .groups }
            .map{ row, state in state.groups.first { $0.order == row }}
            .unwrap()
            .map{ .accountGroupSelected(model: $0) }
            .bind(to: _completeCoordinationResult)
            .disposed(by: bag)

        // Add
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
        
        // Add/Edit Result for accounts
        _addEditAccountResult
            .withLatestFrom(latestState) { result, data -> [AccountDto]? in
                var accounts = data.accounts
                switch result {
                case .accountAdded(let accountDto): accounts.append(accountDto)
                case .accountEdited(let accountDto):
                    accounts.removeAll(where: { $0.id == accountDto.id })
                    accounts.append(accountDto)
                default: return nil
                }
                return accounts
            }
            .unwrap()
            .bind(to: loadedAccounts)
            .disposed(by: bag)
        
        // Add/Edit Result for account group
        _addEditAccountResult
            .withLatestFrom(latestState) { result, data -> [AccountGroupDto]? in
                var accountGroups = data.groups
                switch result {
                case .accountGroupAdded(let accountGroupDto): accountGroups.append(accountGroupDto)
                case .accountGroupEdited(let accountGroupDto):
                    accountGroups.removeAll(where: { $0.id == accountGroupDto.id })
                    accountGroups.append(accountGroupDto)
                default: return nil
                }
                return accountGroups
            }
            .unwrap()
            .bind(to: loadedAccountGroups)
            .disposed(by: bag)

        // Changing order
        _changeOrder
            .withLatestFrom(latestState) { (orderSet: $0, state: $1) }
            .flatMap{ [unowned self] dataSet -> Single<Void> in
                switch dataSet.state.tab {
                case .accounts:
                    
                    let accountsToUpdate = self.orderService.changeOrder(from: dataSet.orderSet.fromIndex, to: dataSet.orderSet.toIndex, in: dataSet.state.accounts)
                    let idsToUpdate = accountsToUpdate.map{ $0.id }
                    
                    var accounts = self.loadedAccounts.value
                    accounts.removeAll(where: { idsToUpdate.contains($0.id) })
                    accounts.append(contentsOf: accountsToUpdate)
                    self.loadedAccounts.accept(accounts)

                    return self.accountsService.updateAccounts(accountsToUpdate)
        
                case .groups:
                    let accountGroupsToUpdate = self.orderService.changeOrder(from: dataSet.orderSet.fromIndex, to: dataSet.orderSet.toIndex, in: dataSet.state.groups)
                    let idsToUpdate = accountGroupsToUpdate.map{ $0.id }
                    
                    var accountGroups = self.loadedAccountGroups.value
                    accountGroups.removeAll(where: { idsToUpdate.contains($0.id) })
                    accountGroups.append(contentsOf: accountGroupsToUpdate)
                    self.loadedAccountGroups.accept(accountGroups)
                    
                    return self.accountsService.updateAccountGroups(accountGroupsToUpdate)
                }
            }
            .subscribe()
            .disposed(by: bag)
        
        // Editing rows
        _rowEditTap
            .withLatestFrom(latestState) { row, state -> AddEditAccountSceneState? in
                switch state.tab {
                case .accounts: return state.accounts.first{ $0.order == row }.flatMap{ .editAccount($0) }
                case .groups: return state.groups.first{ $0.order == row }.flatMap{ .editAccountGroup($0) }
                }
            }
            .unwrap()
            .bind(to: _openAddEditAccount)
            .disposed(by: bag)
        
        // Deleting rows
        _rowDeleteTap
            .withLatestFrom(latestState) { row, state -> AccountDto? in
                if case .accounts = state.tab { return state.accounts.first{ $0.order == row }}
                return nil
            }
            .unwrap()
            .withLatestFrom(loadedAccounts) { [unowned self] accountToDelete, accounts in
                var accounts = accounts
                accounts.removeAll(where: { $0.id == accountToDelete.id })
                self.loadedAccounts.accept(accounts)
                return accountToDelete
            }
            .flatMap{ [unowned self] in self.accountsService.deleteAccount($0) }
            .subscribe()
            .disposed(by: bag)
        
        _rowDeleteTap
            .withLatestFrom(latestState) { row, state -> AccountGroupDto? in
                if case .groups = state.tab { return state.groups.first{ $0.order == row } }
                return nil
            }
            .unwrap()
            .withLatestFrom(loadedAccountGroups) { [unowned self] accountGroupToDelete, accountGroups in
                var accountGroups = accountGroups
                accountGroups.removeAll(where: { $0.id == accountGroupToDelete.id })
                self.loadedAccountGroups.accept(accountGroups)
                return accountGroupToDelete
            }
            .flatMap{ [unowned self] in self.accountsService.deleteAccountGroup($0) }
            .subscribe()
            .disposed(by: bag)
        
        // TableView Data Source
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
        case .account(let viewModel): return viewModel.getActualModel().id
        case .accountGroup(let viewModel): return viewModel.getActualModel().id
        }
    }
    
    static func == (lhs: AccountsListTableItem, rhs: AccountsListTableItem) -> Bool {
        switch (lhs, rhs) {
        case (.account(let viewModel1), .account(let viewModel2)): return viewModel1.getActualModel() == viewModel2.getActualModel()
        case (.accountGroup(let viewModel1), .accountGroup(let viewModel2)): return viewModel1.getActualModel() == viewModel2.getActualModel()
        default: return false
        }
    }
}
