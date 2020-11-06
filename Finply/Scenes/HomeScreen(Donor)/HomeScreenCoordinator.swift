//
//  HomeScreenCoordinator.swift
//  Finply
//
//  Created by Illia Postoienko on 30.09.2020.
//

import UIKit
import RxSwift
import Dip

final class HomeScreenCoordinator: BaseCoordinator<Void> {

    let dependencyContainer: DependencyContainer
    let bag = DisposeBag()
    private(set) var viewController = HomeScreenViewController.instantiate()
    
    init(dependencyContainer: DependencyContainer) {
        self.dependencyContainer = dependencyContainer
    }

    override func start() -> Observable<Void> {

        guard let viewModel = try? dependencyContainer.resolve() as HomeScreenViewModelType else { return Observable.never() }
        
        viewController.bind(to: viewModel)

        viewModel.addButtonPressed
            .flatMap{ [unowned self] _ in
                self.coordinateToAddOperation()
            }
            .subscribe(onNext: { _ in
                
            })
            .disposed(by: bag)
        
        viewModel.accountsListPressed
            .flatMap{ [unowned self] _ in
                self.coordinateToAccountsList()
            }
            .subscribe(onNext: { _ in
                
            })
            .disposed(by: bag)

        return Observable.never()
    }
    
    // MARK: - Coordination
    private func coordinateToAddOperation() -> Observable<AddEditOperationCoordinationResult> {
        let coordinator = AddEditOperationCoordinator(presentingViewController: viewController, dependencyContainer: dependencyContainer)
        return coordinate(to: coordinator)
    }
    
    private func coordinateToEditOperation(_ operation: FPOperation) -> Observable<AddEditOperationCoordinationResult> {
        let coordinator = AddEditOperationCoordinator(presentingViewController: viewController,
                                                      dependencyContainer: dependencyContainer,
                                                      operationToEdit: operation)
        return coordinate(to: coordinator)
    }
    
    private func coordinateToAccountsList() -> Observable<AccountsListCoordinationResult> {
        let coordinator = AccountsListCoordinator(presentingViewController: viewController, dependencyContainer: dependencyContainer)
        return coordinate(to: coordinator)
    }
}
