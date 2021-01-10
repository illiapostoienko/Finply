//  
//  AccountDetailsCoordinator.swift
//  Finply
//
//  Created by Illia Postoienko on 06.11.2020.
//

import UIKit
import RxSwift
import Dip

enum AccountDetailsSceneState {
    case none
    case accountSelected(AccountDto)
    case accountGroupSelected(AccountGroupDto)
}

final class AccountDetailsCoordinator: BaseCoordinator<Void> {
    
    private let dependencyContainer: DependencyContainer
    private var accountDetailsVc: AccountDetailsViewController
    private let basePageViewController: UIPageViewController
    
    private let bag = DisposeBag()
    
    init(accountDetailsVc: AccountDetailsViewController, basePageViewController: UIPageViewController, dependencyContainer: DependencyContainer) {
        self.accountDetailsVc = accountDetailsVc
        self.basePageViewController = basePageViewController
        self.dependencyContainer = dependencyContainer
    }
    
    private(set) var viewController = AccountDetailsViewController.instantiate()
    
    //swiftlint:disable cyclomatic_complexity
    override func start() -> Observable<Void> {
        
        guard let viewModel = try? dependencyContainer.resolve() as AccountDetailsViewModelType else { return Observable.never() }

        accountDetailsVc.bind(to: viewModel)
        accountDetailsVc.delegate = self
        
        viewModel.coordination.addOperation
            .flatMap{ [unowned self] _ in self.coordinateToAddEditOperation() }
            .subscribe(onNext: {
                switch $0 {
                case .operationAdded(let model): return // pass to vm
                default: return
                }
            })
            .disposed(by: bag)
        
//        viewModel.coordination.editOperation
//            .flatMap{ [unowned self] in self.coordinateToAddEditOperation(operationToEdit: $0) }
//            .subscribe(onNext: {
//                switch $0 {
//                case .operationEdited(let model): return // pass to vm
//                default: return
//                }
//            })
//            .disposed(by: bag)
        
        viewModel.coordination.reportDetails
            .flatMap{ [unowned self] in self.coordinateToReportDetails() }
            .subscribe(onNext: {
                switch $0 {
                case .cancel: return
                }
            })
            .disposed(by: bag)

        viewModel.coordination.accountsList
            .flatMap{ [ unowned self] in self.coordinateToAccountsList() }
            .subscribe(onNext: {
                switch $0 {
                case .back: return
                case .accountSelected(let account): return // pass to vm
                case .accountGroupSelected(let accountGroup): return // pass to vm
                }
            })
            .disposed(by: bag)
        
//        viewModel.coordination.editAccount
//            .flatMap{ [ unowned self] in self.coordinateToEditAccount(accountToEdit: $0) }
//            .subscribe(onNext: {
//                switch $0 {
//                case .accountEdited(let model): return // pass to vm
//                default: return
//                }
//            })
//            .disposed(by: bag)
        
        viewModel.coordination.profile
            .flatMap{ [ unowned self] in self.coordinateToProfileDetails() }
            .subscribe(onNext: {
                switch $0 {
                case .cancel: return
                }
            })
            .disposed(by: bag)
        
        return Observable.never()
    }
    
    // MARK: - Coordination
    private func coordinateToAddEditOperation(operationToEdit: OperationDto? = nil) -> Observable<AddEditOperationCoordinationResult> {
        let coordinator = AddEditOperationCoordinator(presentingViewController: accountDetailsVc,
                                                      dependencyContainer: dependencyContainer,
                                                      operationToEdit: operationToEdit)
        return coordinate(to: coordinator)
    }
    
    private func coordinateToReportDetails() -> Observable<ReportDetailsCoordinationResult> {
        let coordinator = ReportDetailsCoordinator(presentingViewController: accountDetailsVc,
                                                   dependencyContainer: dependencyContainer)
        return coordinate(to: coordinator)
    }

    private func coordinateToAccountsList() -> Observable<AccountsListCoordinationResult> {
        let coordinator = AccountsListCoordinator(presentingViewController: accountDetailsVc,
                                                  dependencyContainer: dependencyContainer)
        return coordinate(to: coordinator)
    }
    
    private func coordinateToEditAccount(accountToEdit: AccountDto) -> Observable<AddEditAccountCoordinationResult> {
        let coordinator = AddEditAccountCoordinator(state: .editAccount(accountToEdit),
                                                    presentingViewController: accountDetailsVc,
                                                    dependencyContainer: dependencyContainer)
        return coordinate(to: coordinator)
    }
    
    private func coordinateToProfileDetails() -> Observable<ProfileDetailsCoordinationResult> {
        let coordinator = ProfileDetailsCoordinator(presentingViewController: accountDetailsVc,
                                                    dependencyContainer: dependencyContainer)
        return coordinate(to: coordinator)
    }
}

extension AccountDetailsCoordinator: AccountDetailsViewControllerDelegate {
    
    func tableViewStateChanged(to state: AccountDetailsViewController.TableState) {
        switch state {
        case .collapsed: basePageViewController.setScrollEnabled(true)
        default: basePageViewController.setScrollEnabled(false)
        }
    }
}
