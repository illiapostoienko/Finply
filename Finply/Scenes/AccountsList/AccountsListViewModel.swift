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
    var isEditModeEnabled: Driver<Bool> { get }
}

protocol AccountsListViewModelInput {
    var backButtonTap: AnyObserver<Void> { get }
    var editButtonTap: AnyObserver<Void> { get }
    var addButtonTap: AnyObserver<Void> { get }
    var tabButtonTap: AnyObserver<AccountsListTab> { get }
    var rowSelected: AnyObserver<Int> { get }
    var deleteRowIntent: AnyObserver<Int> { get }
    var changeOrderIntent: AnyObserver<(fromIndex: Int, toIndex: Int)> { get }
    
    var accountAdded: AnyObserver<FPAccount> { get }
    var accountEdited: AnyObserver<FPAccount> { get }
    var accountGroupAdded: AnyObserver<FPAccountGroup> { get }
    var accountGroupEdited: AnyObserver<FPAccountGroup> { get }
}

protocol AccountsListViewModelCoordination {
    var back: Observable<Void> { get }
    var addAccount: Observable<Void> { get }
    var addGroup: Observable<Void> { get }
    var editAccount: Observable<FPAccount> { get }
    var editAccountGroup: Observable<FPAccountGroup> { get }
    var accountSelected: Observable<FPAccount> { get }
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
    var isEditModeEnabled: Driver<Bool> { _isEditModeEnabled.asDriver() }
    
    // Input
    var backButtonTap: AnyObserver<Void> { _backTapStream.asObserver() }
    var editButtonTap: AnyObserver<Void> { _editTapStream.asObserver() }
    var addButtonTap: AnyObserver<Void> { _addTapStream.asObserver() }
    var tabButtonTap: AnyObserver<AccountsListTab> { _tabTapStream.asObserver() }
    var rowSelected: AnyObserver<Int> { _rowSelectedStream.asObserver() }
    var deleteRowIntent: AnyObserver<Int> { _deleteRowStream.asObserver() }
    var changeOrderIntent: AnyObserver<(fromIndex: Int, toIndex: Int)> { _changeOrderStream.asObserver() }
    
    var accountAdded: AnyObserver<FPAccount> { _accountAddedStream.asObserver() }
    var accountEdited: AnyObserver<FPAccount> { _accountEditedStream.asObserver() }
    var accountGroupAdded: AnyObserver<FPAccountGroup> { _accountGroupAddedStream.asObserver() }
    var accountGroupEdited: AnyObserver<FPAccountGroup> { _accountGroupEditedStream.asObserver() }
    
    // Coordination
    var back: Observable<Void> { _backTapStream }
    var addAccount: Observable<Void> { _addTapStream.withLatestFrom(_currentTab).filter{ $0 == .accounts }.ignoreContent() }
    var addGroup: Observable<Void> { _addTapStream.withLatestFrom(_currentTab).filter{ $0 == .groups }.ignoreContent() }
    var editAccount: Observable<FPAccount>
    var editAccountGroup: Observable<FPAccountGroup>
    var accountSelected: Observable<FPAccount>
    var accountGroupSelected: Observable<FPAccountGroup>

    // Local Streams
    private let _backTapStream = PublishSubject<Void>()
    private let _editTapStream = PublishSubject<Void>()
    private let _addTapStream = PublishSubject<Void>()
    private let _tabTapStream = PublishSubject<AccountsListTab>()
    private let _rowSelectedStream = PublishSubject<Int>()
    private let _deleteRowStream = PublishSubject<Int>()
    private let _changeOrderStream = PublishSubject<(fromIndex: Int, toIndex: Int)>()
    
    private var _accountAddedStream = PublishSubject<FPAccount>()
    private var _accountEditedStream = PublishSubject<FPAccount>()
    private var _accountGroupAddedStream = PublishSubject<FPAccountGroup>()
    private var _accountGroupEditedStream = PublishSubject<FPAccountGroup>()
    
    private let _currentTab = BehaviorRelay<AccountsListTab>(value: .accounts)
    private let _dataSource = BehaviorRelay<[AccountsListTableItem]>(value: [])
    private let _isEditModeEnabled = BehaviorRelay<Bool>(value: false)
    
    private let loadedAccounts = BehaviorRelay<[FPAccount]>(value: [])
    private let loadedGroups = BehaviorRelay<[FPAccountGroup]>(value: [])
    
    private let bag = DisposeBag()
    
    init() {
        _tabTapStream.bind(to: _currentTab).disposed(by: bag)
        
        _editTapStream
            .withLatestFrom(_isEditModeEnabled)
            .toggle()
            .bind(to: _isEditModeEnabled)
            .disposed(by: bag)
        
        editAccount = _rowSelectedStream
            .withLatestFrom(Observable.combineLatest(_isEditModeEnabled, _currentTab, loadedAccounts)) { selectedRow, dataSet -> FPAccount? in
                guard dataSet.0, dataSet.1 == .accounts else { return nil }
                return dataSet.2[safe: selectedRow]
            }
            .unwrap()
        
        editAccountGroup = _rowSelectedStream
            .withLatestFrom(Observable.combineLatest(_isEditModeEnabled, _currentTab, loadedGroups)) { selectedRow, dataSet -> FPAccountGroup? in
                guard dataSet.0, dataSet.1 == .groups else { return nil }
                return dataSet.2[safe: selectedRow]
            }
            .unwrap()
        
        accountSelected = Observable.combineLatest(_currentTab, _rowSelectedStream, loadedAccounts)
            .map{ tab, index, accounts -> FPAccount? in
                guard tab == .accounts else { return nil }
                return accounts[safe: index]
            }
            .unwrap()
            
        accountGroupSelected = Observable.combineLatest(_currentTab, _rowSelectedStream, loadedGroups)
            .map{ tab, index, groups -> FPAccountGroup? in
                guard tab == .groups else { return nil }
                return groups[safe: index]
            }
            .unwrap()
        
        // _accountAddedStream -> add to loadedAccounts
        // _accountEditedStream  -> find and edit in loadedAccounts
        // _accountGroupAddedStream -> add loadedGroups
        // _accountGroupEditedStream -> find and edit in loadedGroups
        
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
        let mocks: [FPAccount] = [
            FPAccount(id: UUID(), name: "Account 1", baseValue: 0.0, calculatedValue: 0.0, currency: "UAH", order: 0),
            FPAccount(id: UUID(), name: "Account 1", baseValue: 0.0, calculatedValue: 0.0, currency: "UAH", order: 1),
            FPAccount(id: UUID(), name: "Account 1", baseValue: 0.0, calculatedValue: 0.0, currency: "UAH", order: 2),
            FPAccount(id: UUID(), name: "Account 1", baseValue: 0.0, calculatedValue: 0.0, currency: "UAH", order: 3),
            FPAccount(id: UUID(), name: "Account 1", baseValue: 0.0, calculatedValue: 0.0, currency: "UAH", order: 4),
            FPAccount(id: UUID(), name: "Account 1", baseValue: 0.0, calculatedValue: 0.0, currency: "UAH", order: 5),
            FPAccount(id: UUID(), name: "Account 1", baseValue: 0.0, calculatedValue: 0.0, currency: "UAH", order: 6),
            FPAccount(id: UUID(), name: "Account 1", baseValue: 0.0, calculatedValue: 0.0, currency: "UAH", order: 7)
        ]
        
        loadedAccounts.accept(mocks)
    }
}

enum AccountsListTableItem: IdentifiableType, Equatable {
    case account(viewModel: AccountsListAccountCellViewModelType)
    case group(viewModel: AccountsListGroupCellViewModelType)
    
    var identity: String {
        switch self {
        case .account(let viewModel): return viewModel.accountModel.id.uuidString
        case .group(let viewModel): return viewModel.accountGroupModel.id.uuidString
        }
    }
    
    static func == (lhs: AccountsListTableItem, rhs: AccountsListTableItem) -> Bool {
        return lhs.identity == rhs.identity
    }
}
