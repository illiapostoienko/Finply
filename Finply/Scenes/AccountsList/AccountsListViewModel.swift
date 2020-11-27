//
//  AccountsListViewModel.swift
//  Finply
//
//  Created by Illia Postoienko on 23.10.2020.
//

import RxSwift
import RxCocoa
import RxDataSources

protocol AccountsListViewModelType {
    
    //Output
    var dataSource: Observable<[AccountsListTableItem]> { get }
    var currentTab: Driver<AccountsListTab> { get }
    var isEditModeEnabled: Driver<Bool> { get }
    
    //Input
    var backButtonTap: PublishSubject<Void> { get }
    var editButtonTap: PublishSubject<Void> { get }
    var addButtonTap: PublishSubject<Void> { get }
    var tabButtonTap: PublishSubject<AccountsListTab> { get }
    var rowSelected: PublishSubject<Int> { get }
    var deleteRowIntent: PublishSubject<Int> { get }
    var changeOrderIntent: PublishSubject<(fromIndex: Int, toIndex: Int)> { get }
}

enum AccountsListTab {
    case accounts
    case groups
    case all
}

enum AccountsListTableItem {
    case account(viewModel: AccountsListAccountCellViewModelType)
    case group(viewModel: AccountsListGroupCellViewModelType)
}

final class AccountsListViewModel: AccountsListViewModelType {
    
    //Output
    var dataSource: Observable<[AccountsListTableItem]>
    var currentTab: Driver<AccountsListTab>
    var isEditModeEnabled: Driver<Bool>
    
    //Input
    let backButtonTap = PublishSubject<Void>()
    let editButtonTap = PublishSubject<Void>()
    let addButtonTap = PublishSubject<Void>()
    let tabButtonTap = PublishSubject<AccountsListTab>()
    let rowSelected = PublishSubject<Int>()
    let deleteRowIntent = PublishSubject<Int>()
    let changeOrderIntent = PublishSubject<(fromIndex: Int, toIndex: Int)>()
    
    //Coordination
    // addButtonTap -> add group/account
    // rowSelected -> return to accountDetails with selected wallet
    
    private let _currentTab = BehaviorRelay<AccountsListTab>(value: .accounts)
    private let _dataSource = BehaviorRelay<[AccountsListTableItem]>(value: [])
    private let _isEditModeEnabled = BehaviorRelay<Bool>(value: false)
    private let bag = DisposeBag()
    
    init() {
        dataSource = _dataSource.asObservable()
        currentTab = _currentTab.asDriver()
        isEditModeEnabled = _isEditModeEnabled.asDriver()
        
        tabButtonTap.bind(to: _currentTab).disposed(by: bag)
        
        editButtonTap
            .withLatestFrom(_isEditModeEnabled)
            .toggle()
            .bind(to: _isEditModeEnabled)
            .disposed(by: bag)
        
        //deleteRowIntent
        
        //changeOrderIntent
        
        
        let mocks: [AccountsListTableItem] = [
            .account(viewModel: AccountsListAccountCellViewModel()),
            .account(viewModel: AccountsListAccountCellViewModel()),
            .account(viewModel: AccountsListAccountCellViewModel()),
            .account(viewModel: AccountsListAccountCellViewModel()),
            .account(viewModel: AccountsListAccountCellViewModel()),
            .account(viewModel: AccountsListAccountCellViewModel()),
            .account(viewModel: AccountsListAccountCellViewModel()),
            .account(viewModel: AccountsListAccountCellViewModel()),
            .account(viewModel: AccountsListAccountCellViewModel()),
            .account(viewModel: AccountsListAccountCellViewModel()),
            .account(viewModel: AccountsListAccountCellViewModel()),
        ]
        
        _dataSource.accept(mocks)
    }
}

extension AccountsListTableItem: IdentifiableType, Equatable {
    
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
