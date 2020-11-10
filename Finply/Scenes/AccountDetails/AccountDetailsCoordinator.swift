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
    
    override func start() -> Observable<Void> {
        
        guard let viewModel = try? dependencyContainer.resolve() as AccountDetailsViewModelType else { return Observable.never() }

        viewController.bind(to: viewModel)
        
        viewModel.coordinationAddOperation
            .flatMap{ [unowned self] _ in self.coordinateToAddOperation() }
            .subscribe(onNext: {
                switch $0 {
                case .cancel: return
                case .addedOperation(let _): return // pass to vm
                case .editedOperation(let _): return // pass to vm
                }
            })
            .disposed(by: bag)
        
        viewModel.coordinationAccountsList
            .flatMap{ [ unowned self] in self.coordinateToAccountsList() }
            .subscribe(onNext: {
                switch $0 {
                
                }
            })
        
        return Observable.never()
    }
    
    // MARK: - Coordination
    private func coordinateToAddOperation() -> Observable<AddEditOperationCoordinationResult> {
        let coordinator = AddEditOperationCoordinator(presentingViewController: viewController, dependencyContainer: dependencyContainer)
        return coordinate(to: coordinator)
    }
    
    private func coordinateToAccountsList() -> Observable<AccountsListCoordinationResult> {
        let coordinator = AccountsListCoordinator(presentingViewController: viewController, dependencyContainer: dependencyContainer)
        return coordinate(to: coordinator)
    }
}
