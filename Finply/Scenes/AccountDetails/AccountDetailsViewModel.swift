//  
//  AccountDetailsViewModel.swift
//  Finply
//
//  Created by Illia Postoienko on 06.11.2020.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

protocol AccountDetailsViewModelInput {
    var addButtonTap: AnyObserver<Void> { get }
    var rowSelected: AnyObserver<IndexPath> { get }
}

protocol AccountDetailsViewModelOutput {
    var dataSource: Observable<[AccountOperationsTableSection]> { get }
    var currentOperationSections: BehaviorRelay<[OperationsSection]> { get }
}

protocol AccountDetailsViewModelCoordination {
    var addOperation: Observable<Void> { get }
    var editOperation: Observable<FPOperation> { get }
    var reportDetails: Observable<Void> { get }
    var accountsList: Observable<Void> { get }
    //var editAccount: Observable<AccountDto> { get }
    var profile: Observable<Void> { get }
}

protocol AccountDetailsViewModelType {
    
    var accountHeaderViewModel: AccountHeaderViewModelType { get }
    var accountMonthDetailsViewModel: AccountMonthDetailsViewModelType { get }
    
    var input: AccountDetailsViewModelInput { get }
    var output: AccountDetailsViewModelOutput { get }
    var coordination: AccountDetailsViewModelCoordination { get }
}

final class AccountDetailsViewModel: AccountDetailsViewModelType, AccountDetailsViewModelInput, AccountDetailsViewModelOutput, AccountDetailsViewModelCoordination {
    
    var accountHeaderViewModel: AccountHeaderViewModelType
    var accountMonthDetailsViewModel: AccountMonthDetailsViewModelType
    
    var input: AccountDetailsViewModelInput { return self }
    var output: AccountDetailsViewModelOutput { return self }
    var coordination: AccountDetailsViewModelCoordination { return self }
    
    // Input
    var addButtonTap: AnyObserver<Void> { _addTapStream.asObserver() }
    var rowSelected: AnyObserver<IndexPath> { _rowSelectedStream.asObserver() }
    
    // Output
    let dataSource: Observable<[AccountOperationsTableSection]>
    let currentOperationSections: BehaviorRelay<[OperationsSection]>
    
    // Coordination
    var addOperation: Observable<Void> { _addTapStream }
    var editOperation: Observable<FPOperation>
    var reportDetails: Observable<Void> { accountMonthDetailsViewModel.reportDetailsTap }
    var accountsList: Observable<Void> { accountHeaderViewModel.accountTap }
    
    //var editAccount: Observable<AccountDto> { accountHeaderViewModel.editAccountTap.withLatestFrom(_currentAccount) }
    
    var profile: Observable<Void> { accountHeaderViewModel.profileTap }
    
    // Local Streams
    private let _addTapStream = PublishSubject<Void>()
    private let _rowSelectedStream = PublishSubject<IndexPath>()
    private let _sceneState: BehaviorRelay<AccountDetailsSceneState> = BehaviorRelay<AccountDetailsSceneState>(value: .none)
    private let loadedOperations = BehaviorRelay<[AccountDto]>(value: [])
    
    private let userStateService: UserStateServiceType
    private let bag = DisposeBag()
    
    init(accountHeaderViewModel: AccountHeaderViewModelType = AccountHeaderViewModel(),
         accountMonthDetailsViewModel: AccountMonthDetailsViewModelType = AccountMonthDetailsViewModel(),
         userStateService: UserStateServiceType)
    {
        self.userStateService = userStateService
        self.accountHeaderViewModel = accountHeaderViewModel
        self.accountMonthDetailsViewModel = accountMonthDetailsViewModel
        
        currentOperationSections = BehaviorRelay<[OperationsSection]>(value: mockData)
    
        dataSource = currentOperationSections
            .map{
                $0.map{
                    .operations(date: $0.date, items: $0.cells.map{ .operation(viewModel: $0) })
                }
            }
        
        editOperation = _rowSelectedStream
            .withLatestFrom(currentOperationSections) { indexPath, sections in
                sections[safe: indexPath.section]
                    .flatMap{ section in section.cells[safe: indexPath.item] }
                    .flatMap{ cell in cell.operation }
            }
            .unwrap()
    }
}

// MARK: - Animatable Section

struct OperationsSection {
    let date: Date
    let cells: [AccountOperationCellViewModelType]
}

private var mockData: [OperationsSection] = {
    return [
        OperationsSection(date: Date(timeIntervalSince1970: 1604620800), cells: [
                            AccountOperationCellViewModel(),
                            AccountOperationCellViewModel()
        ]),
        OperationsSection(date: Date(timeIntervalSince1970: 1604534400), cells: [
                            AccountOperationCellViewModel(),
                            AccountOperationCellViewModel()
        ]),
        OperationsSection(date: Date(timeIntervalSince1970: 1604448000), cells: [
                            AccountOperationCellViewModel(),
                            AccountOperationCellViewModel()
        ]),
        OperationsSection(date: Date(timeIntervalSince1970: 1604361600), cells: [
                            AccountOperationCellViewModel(),
                            AccountOperationCellViewModel()
        ]),
        OperationsSection(date: Date(timeIntervalSince1970: 1604275200), cells: [
                            AccountOperationCellViewModel(),
                            AccountOperationCellViewModel()
        ]),
        OperationsSection(date: Date(timeIntervalSince1970: 1604188800), cells: [
                            AccountOperationCellViewModel(),
                            AccountOperationCellViewModel()
        ]),
        OperationsSection(date: Date(timeIntervalSince1970: 1604102400), cells: [
                            AccountOperationCellViewModel(),
                            AccountOperationCellViewModel()
        ])
    ]
}()

enum AccountOperationsTableSection: IdentifiableType, AnimatableSectionModelType {
    
    case operations(date: Date, items: [AccountOperationsTableItem])
    
    var identity: String {
        switch self {
        case .operations: return "operations"
        }
    }
    
    var titleDate: Date? {
        switch self {
        case .operations(let date, items: _): return date
        }
    }
    
    var items: [AccountOperationsTableItem] {
        switch  self {
        case .operations(date: _, let items): return items
        }
    }
    
    init(original: AccountOperationsTableSection, items: [AccountOperationsTableItem]) {
        switch original {
        case .operations(let date, items: _):
            self = .operations(date: date, items: items)
        }
    }
}

enum AccountOperationsTableItem: IdentifiableType, Equatable {
    
    case operation(viewModel: AccountOperationCellViewModelType)
    
    var identity: String {
        switch self {
        case .operation(let vm): return vm.operation.id.uuidString
        }
    }
    
    static func == (lhs: AccountOperationsTableItem, rhs: AccountOperationsTableItem) -> Bool {
        guard case .operation(let lhsVM) = lhs, case .operation(let rhsVM) = rhs else {
            return lhs.identity == rhs.identity
        }

        return lhsVM.operation.id == rhsVM.operation.id
    }
}
