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
    
    var dataSource: Observable<[AccountOperationsTableSection]> { get }
    var currentOperationSections: BehaviorRelay<[OperationsSection]> { get }
    
    var coordinationReportDetails: Observable<Void> { get }
    var coordinationAddOperation: Observable<Void> { get }
    var coordinationAccountsList: Observable<Void> { get }
}

final class AccountDetailsViewModel: AccountDetailsViewModelType {
    
    var accountHeaderViewModel: AccountHeaderViewModelType
    var accountMonthDetailsViewModel: AccountMonthDetailsViewModelType
    
    let dataSource: Observable<[AccountOperationsTableSection]>
    let currentOperationSections: BehaviorRelay<[OperationsSection]>
    
    var coordinationReportDetails: Observable<Void> { _coordinationReportDetails }
    private let _coordinationReportDetails = PublishSubject<Void>()
    
    var coordinationAddOperation: Observable<Void> { _coordinationAddOperation }
    private let _coordinationAddOperation = PublishSubject<Void>()
    
    var coordinationAccountsList: Observable<Void> { _coordinationAccountsList }
    private let _coordinationAccountsList = PublishSubject<Void>()
    
    private let bag = DisposeBag()
    
    init(accountHeaderViewModel: AccountHeaderViewModelType = AccountHeaderViewModel(),
         accountMonthDetailsViewModel: AccountMonthDetailsViewModelType = AccountMonthDetailsViewModel()) {
        self.accountHeaderViewModel = accountHeaderViewModel
        self.accountMonthDetailsViewModel = accountMonthDetailsViewModel
        
        accountMonthDetailsViewModel.reportDetailsTap
            .bind(to: _coordinationReportDetails)
            .disposed(by: bag)
        
        currentOperationSections = BehaviorRelay<[OperationsSection]>(value: mockData)
    
        dataSource = currentOperationSections
            .map{ $0.map{ section in .operations(date: section.date, items: section.cells.map{ .operation(viewModel: $0) }) } }
    }
}

// MARK: - Animatable Section

struct OperationsSection {
    let date: Date
    let cells: [AccountOperationCellViewModelType]
}

fileprivate var mockData: [OperationsSection] = {
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
        case .operation(let vm): return vm.operationId.uuidString
        }
    }
    
    static func == (lhs: AccountOperationsTableItem, rhs: AccountOperationsTableItem) -> Bool {
        guard case .operation(let lhsVM) = lhs, case .operation(let rhsVM) = rhs else {
            return lhs.identity == rhs.identity
        }

        return lhsVM.operationId == rhsVM.operationId
    }
}
