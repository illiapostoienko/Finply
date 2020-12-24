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
    private let loadedAccounts = BehaviorRelay<[AccountModelType]>(value: [])
    private let loadedAccountGroups = BehaviorRelay<[AccountGroupModelType]>(value: [])
    
    private var accountItems: Observable<[AccountsListTableItem]> {
        loadedAccounts.map{ $0.map { .account(viewModel: AccountsListAccountCellViewModel(accountModel: $0)) }}
    }
    
    private var groupItems: Observable<[AccountsListTableItem]> {
        loadedAccountGroups.map{ $0.map { .group(viewModel: AccountsListGroupCellViewModel(accountGroupModel: $0)) }}
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
        
        // edit on cell -> _openAddEditAccount
        // delete on cell -> delete from loaded list
        // _addEditAccountResult -> parse and add/edit cells
        // changeOrderIntent -> change order
        
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
            .flatMap{ [unowned self] in self.accountsService.getOrderedAccounts() }
            .bind(to: loadedAccounts)
            .disposed(by: bag)
        
        _reload
            .flatMap{ [unowned self] in self.accountsService.getOrderedAccountGroups() }
            .bind(to: loadedAccountGroups)
            .disposed(by: bag)
    }
}

enum AccountsListTableItem: IdentifiableType, Equatable {
    case account(viewModel: AccountsListAccountCellViewModelType)
    case group(viewModel: AccountsListGroupCellViewModelType)
    
    var identity: String {
        switch self {
        case .account(let viewModel): return viewModel.getAccountId()
        case .group(let viewModel): return viewModel.getAccountGroupId()
        }
    }
    
    static func == (lhs: AccountsListTableItem, rhs: AccountsListTableItem) -> Bool {
        return lhs.identity == rhs.identity
    }
}
