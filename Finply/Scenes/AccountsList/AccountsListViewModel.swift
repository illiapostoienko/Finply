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

protocol AccountsListViewModelOutput {
    var dataSource: Observable<[AccountsListTableItem]> { get }
}

protocol AccountsListViewModelInput {
    var backButtonTap: AnyObserver<Void> { get }
    var addButtonTap: AnyObserver<Void> { get }
    var tabButtonTap: AnyObserver<AccountsListTab> { get }
    var rowSelected: AnyObserver<Int> { get }
    var editRowIntent: AnyObserver<Int> { get }
    var deleteRowIntent: AnyObserver<Int> { get }
    var changeOrderIntent: AnyObserver<(fromIndex: Int, toIndex: Int)> { get }
    
    var accountAdded: AnyObserver<AccountModelType> { get }
    var accountEdited: AnyObserver<AccountModelType> { get }
    var accountGroupAdded: AnyObserver<FPAccountGroup> { get }
    var accountGroupEdited: AnyObserver<FPAccountGroup> { get }
}

protocol AccountsListViewModelCoordination {
    var back: Observable<Void> { get }
    
    var addAccount: Observable<Void> { get }
    var editAccount: Observable<AccountModelType> { get }
    var addAccountGroup: Observable<Void> { get }
    var editAccountGroup: Observable<FPAccountGroup> { get }
    
    var accountSelected: Observable<AccountModelType> { get }
    var accountGroupSelected: Observable<FPAccountGroup> { get }
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
    
    // Input
    var backButtonTap: AnyObserver<Void> { _backTapStream.asObserver() }
    var addButtonTap: AnyObserver<Void> { _addTapStream.asObserver() }
    var tabButtonTap: AnyObserver<AccountsListTab> { _tabTapStream.asObserver() }
    var rowSelected: AnyObserver<Int> { _rowSelectedStream.asObserver() }
    var editRowIntent: AnyObserver<Int> { _editRowStream.asObserver() }
    var deleteRowIntent: AnyObserver<Int> { _deleteRowStream.asObserver() }
    var changeOrderIntent: AnyObserver<(fromIndex: Int, toIndex: Int)> { _changeOrderStream.asObserver() }
    
    var accountAdded: AnyObserver<AccountModelType> { _accountAddedStream.asObserver() }
    var accountEdited: AnyObserver<AccountModelType> { _accountEditedStream.asObserver() }
    var accountGroupAdded: AnyObserver<FPAccountGroup> { _accountGroupAddedStream.asObserver() }
    var accountGroupEdited: AnyObserver<FPAccountGroup> { _accountGroupEditedStream.asObserver() }
    
    // Coordination
    var back: Observable<Void> { _backTapStream }
    var addAccount: Observable<Void> { _addTapStream.withLatestFrom(_currentTab).filter{ $0 == .accounts }.ignoreContent() }
    var addAccountGroup: Observable<Void> { _addTapStream.withLatestFrom(_currentTab).filter{ $0 == .groups }.ignoreContent() }
    var editAccount: Observable<AccountModelType>
    var accountSelected: Observable<AccountModelType>
    var editAccountGroup: Observable<FPAccountGroup>
    var accountGroupSelected: Observable<FPAccountGroup>

    // Local Streams
    private let _backTapStream = PublishSubject<Void>()
    private let _addTapStream = PublishSubject<Void>()
    private let _tabTapStream = PublishSubject<AccountsListTab>()
    private let _rowSelectedStream = PublishSubject<Int>()
    private let _deleteRowStream = PublishSubject<Int>()
    private let _editRowStream = PublishSubject<Int>()
    private let _changeOrderStream = PublishSubject<(fromIndex: Int, toIndex: Int)>()
    
    private var _accountAddedStream = PublishSubject<AccountModelType>()
    private var _accountEditedStream = PublishSubject<AccountModelType>()
    private var _accountGroupAddedStream = PublishSubject<FPAccountGroup>()
    private var _accountGroupEditedStream = PublishSubject<FPAccountGroup>()
    
    private let _currentTab = BehaviorRelay<AccountsListTab>(value: .accounts)
    private let _dataSource = BehaviorRelay<[AccountsListTableItem]>(value: [])
    private let _isEditModeEnabled = BehaviorRelay<Bool>(value: false)
    private let loadedAccounts = BehaviorRelay<[AccountModelType]>(value: [])
    private let loadedGroups = BehaviorRelay<[FPAccountGroup]>(value: [])
    
    //Services
    
    private let bag = DisposeBag()
    
    init() {
        _tabTapStream.bind(to: _currentTab).disposed(by: bag)
        
        let latestState = Observable.combineLatest(_isEditModeEnabled, _currentTab, loadedAccounts, loadedGroups).map{ (isEditMode: $0, tab: $1, accounts: $2, groups: $3) }
        let selectedRowWithLatestData = _rowSelectedStream
            .withLatestFrom(latestState) { ($0, $1) }
        
        editAccount = selectedRowWithLatestData
            .filter{ _, latestState in latestState.isEditMode && latestState.tab == .accounts }
            .map{ $1.accounts[safe: $0] }
            .unwrap()
        
        editAccountGroup = selectedRowWithLatestData
            .filter{ _, latestState in latestState.isEditMode && latestState.tab == .groups }
            .map{ $1.groups[safe: $0] }
            .unwrap()

        accountSelected = selectedRowWithLatestData
            .filter{ _, latestState in !latestState.isEditMode && latestState.tab == .accounts }
            .map{ $1.accounts[safe: $0] }
            .unwrap()

        accountGroupSelected = selectedRowWithLatestData
            .filter{ _, latestState in !latestState.isEditMode && latestState.tab == .groups }
            .map{ $1.groups[safe: $0] }
            .unwrap()
        
        // _accountAddedStream -> add to loadedAccounts
        // _accountEditedStream  -> find and edit in loadedAccounts
        // _accountGroupAddedStream -> add loadedGroups
        // _accountGroupEditedStream -> find and edit in loadedGroups
        
        //editRowIntent -> edit
        //deleteRowIntent -> delete
        //changeOrderIntent -> change order
        
        Observable.combineLatest(_currentTab, loadedAccounts, loadedGroups)
            .map{ tab, accounts, groups -> [AccountsListTableItem] in
                switch tab {
                case .accounts:
                    return accounts
                        .map{ AccountsListAccountCellViewModel(accountModel: $0) }
                        .map{ AccountsListTableItem.account(viewModel: $0) }
                    
                case .groups:
                    return groups
                        .map{ AccountsListGroupCellViewModel(accountGroupModel: $0) }
                        .map{ AccountsListTableItem.group(viewModel: $0) }
                }
            }
            .bind(to: _dataSource)
            .disposed(by: bag)
        
        // load accounts and groups into internal arrays
        let mocks: [AccountModelType] = [
            AccountModel(name: "Some name", baseValueInCents: 0, currency: .afghani, order: 0),
            AccountModel(name: "Some name", baseValueInCents: 0, currency: .afghani, order: 1),
            AccountModel(name: "Some name", baseValueInCents: 0, currency: .afghani, order: 2),
            AccountModel(name: "Some name", baseValueInCents: 0, currency: .afghani, order: 3),
            AccountModel(name: "Some name", baseValueInCents: 0, currency: .afghani, order: 4),
            AccountModel(name: "Some name", baseValueInCents: 0, currency: .afghani, order: 5),
            AccountModel(name: "Some name", baseValueInCents: 0, currency: .afghani, order: 6),
            AccountModel(name: "Some name", baseValueInCents: 0, currency: .afghani, order: 7)
        ]
        
        loadedAccounts.accept(mocks)
    }
}

enum AccountsListTableItem: IdentifiableType, Equatable {
    case account(viewModel: AccountsListAccountCellViewModelType)
    case group(viewModel: AccountsListGroupCellViewModelType)
    
    var identity: String {
        switch self {
        case .account(let viewModel): return viewModel.accountModel.id
        case .group(let viewModel): return viewModel.accountGroupModel.id.uuidString
        }
    }
    
    static func == (lhs: AccountsListTableItem, rhs: AccountsListTableItem) -> Bool {
        return lhs.identity == rhs.identity
    }
}
