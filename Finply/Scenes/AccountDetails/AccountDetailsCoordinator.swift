//  
//  AccountDetailsCoordinator.swift
//  Finply
//
//  Created by Illia Postoienko on 06.11.2020.
//

import UIKit
import RxSwift
import Dip

final class AccountDetailsCoordinator: BaseCoordinator<Void> {
    
    let dependencyContainer: DependencyContainer
    private(set) var viewController = AccountDetailsViewController.instantiate()
    
    private let bag = DisposeBag()
    
    init(dependencyContainer: DependencyContainer) {
        self.dependencyContainer = dependencyContainer
    }
    
    //swiftlint:disable cyclomatic_complexity
    override func start() -> Observable<Void> {
        
        guard let viewModel = try? dependencyContainer.resolve() as AccountDetailsViewModelType else { return Observable.never() }

        viewController.bind(to: viewModel)
        
        viewModel.coordinationAddOperation
            .flatMap{ [unowned self] _ in self.coordinateToAddEditOperation() }
            .subscribe(onNext: {
                switch $0 {
                case .addedOperation: return // pass to vm
                default: return
                }
            })
            .disposed(by: bag)
        
        viewModel.coordinationEditOperation
            .flatMap{ [unowned self] in self.coordinateToAddEditOperation(operationToEdit: $0) }
            .subscribe(onNext: {
                switch $0 {
                case .editedOperation: return // pass to vm
                default: return
                }
            })
            .disposed(by: bag)
        
        viewModel.coordinationReportDetails
            .flatMap{ [unowned self] in self.coordinateToReportDetails() }
            .subscribe(onNext: {
                switch $0 {
                case .cancel: return
                }
            })
            .disposed(by: bag)

        viewModel.coordinationAccountsList
            .flatMap{ [ unowned self] in self.coordinateToAccountsList() }
            .subscribe(onNext: {
                switch $0 {
                case .cancel: return
                case .accountSelected: return // pass to vm
                case .accountsGroupSelected: return // pass to vm
                }
            })
            .disposed(by: bag)
        
        viewModel.coordinationEditAccount
            .flatMap{ [ unowned self] in self.coordinateToEditAccount() }
            .subscribe(onNext: {
                switch $0 {
                case .cancel: return
                }
            })
            .disposed(by: bag)
        
        viewModel.coordinationProfile
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
    private func coordinateToAddEditOperation(operationToEdit: FPOperation? = nil) -> Observable<AddEditOperationCoordinationResult> {
        let coordinator = AddEditOperationCoordinator(presentingViewController: viewController,
                                                      dependencyContainer: dependencyContainer,
                                                      operationToEdit: operationToEdit)
        return coordinate(to: coordinator)
    }
    
    private func coordinateToReportDetails() -> Observable<ReportDetailsCoordinationResult> {
        let coordinator = ReportDetailsCoordinator(presentingViewController: viewController,
                                                   dependencyContainer: dependencyContainer)
        return coordinate(to: coordinator)
    }

    private func coordinateToAccountsList() -> Observable<AccountsListCoordinationResult> {
        let coordinator = AccountsListCoordinator(presentingViewController: viewController,
                                                  dependencyContainer: dependencyContainer)
        return coordinate(to: coordinator)
    }
    
    private func coordinateToEditAccount() -> Observable<AddEditAccountCoordinationResult> {
        let coordinator = AddEditAccountCoordinator(presentingViewController: viewController,
                                                    dependencyContainer: dependencyContainer)
        return coordinate(to: coordinator)
    }
    
    private func coordinateToProfileDetails() -> Observable<ProfileDetailsCoordinationResult> {
        let coordinator = ProfileDetailsCoordinator(presentingViewController: viewController,
                                                    dependencyContainer: dependencyContainer)
        return coordinate(to: coordinator)
    }
}
