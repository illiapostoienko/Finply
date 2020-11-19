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

protocol AccountDetailsViewModelType {
    
    var accountHeaderViewModel: AccountHeaderViewModelType { get }
    var accountMonthDetailsViewModel: AccountMonthDetailsViewModelType { get }
    
    //Input
    var addOperationTap: AnyObserver<Void> { get }
    var cellSelected: AnyObserver<IndexPath> { get }
    
    //Output
    var dataSource: Observable<[AccountOperationsTableSection]> { get }
    var currentOperationSections: BehaviorRelay<[OperationsSection]> { get }
    
    // Coordination
    var coordinationAddOperation: Observable<Void> { get }
    var coordinationEditOperation: Observable<FPOperation> { get }
    var coordinationReportDetails: Observable<Void> { get }
    var coordinationAccountsList: Observable<Void> { get }
    var coordinationEditAccount: Observable<Void> { get }
    var coordinationProfile: Observable<Void> { get }
}

final class AccountDetailsViewModel: AccountDetailsViewModelType {
    
    var accountHeaderViewModel: AccountHeaderViewModelType
    var accountMonthDetailsViewModel: AccountMonthDetailsViewModelType
    
    //Input
    var addOperationTap: AnyObserver<Void> { addOperationStream.asObserver() }
    var cellSelected: AnyObserver<IndexPath> { cellSelectionStream.asObserver() }
    
    //Output
    let dataSource: Observable<[AccountOperationsTableSection]>
    let currentOperationSections: BehaviorRelay<[OperationsSection]>
    
    //Coordination
    var coordinationAddOperation: Observable<Void> { addOperationStream }
    var coordinationEditOperation: Observable<FPOperation>
    var coordinationReportDetails: Observable<Void> { accountMonthDetailsViewModel.reportDetailsTap }
    var coordinationAccountsList: Observable<Void> { accountHeaderViewModel.accountTap }
    var coordinationEditAccount: Observable<Void> { accountHeaderViewModel.editAccountTap }
    var coordinationProfile: Observable<Void> { accountHeaderViewModel.profileTap }
    
    //Locals
    private let addOperationStream = PublishSubject<Void>()
    private let cellSelectionStream = PublishSubject<IndexPath>()
    private let bag = DisposeBag()
    
    init(accountHeaderViewModel: AccountHeaderViewModelType,
         accountMonthDetailsViewModel: AccountMonthDetailsViewModelType) {
        self.accountHeaderViewModel = accountHeaderViewModel
        self.accountMonthDetailsViewModel = accountMonthDetailsViewModel
        
        currentOperationSections = BehaviorRelay<[OperationsSection]>(value: mockData)
    
        dataSource = currentOperationSections
            .map{
                $0.enumerated().map{ index, section in
                    var items: [AccountOperationsTableItem] = section.cells.map{ .operation(viewModel: $0) }
                    if index == 0 { items.insert(.clear, at: 0) }
                    return .operations(date: section.date, items: items)
                }
            }
        
        coordinationEditOperation = cellSelectionStream
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

enum AccountOperationsTableSection {
    case operations(date: Date, items: [AccountOperationsTableItem])
}

enum AccountOperationsTableItem {
    case operation(viewModel: AccountOperationCellViewModelType)
    case clear
}

extension AccountOperationsTableSection: IdentifiableType, AnimatableSectionModelType {
 
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

extension AccountOperationsTableItem: IdentifiableType, Equatable {
    var identity: String {
        switch self {
        case .operation(let vm): return vm.operation.id.uuidString
        case .clear: return "clear"
        }
    }
    
    static func == (lhs: AccountOperationsTableItem, rhs: AccountOperationsTableItem) -> Bool {
        guard case .operation(let lhsVM) = lhs, case .operation(let rhsVM) = rhs else {
            return lhs.identity == rhs.identity
        }

        return lhsVM.operation.id == rhsVM.operation.id
    }
}
