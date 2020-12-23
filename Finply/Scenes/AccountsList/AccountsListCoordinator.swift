//
//  AccountsListCoordinator.swift
//  Finply
//
//  Created by Illia Postoienko on 23.10.2020.
//

import UIKit
import RxSwift
import Dip

enum AccountsListCoordinationResult {
    case back
    case accountSelected(model: AccountModelType)
    case accountGroupSelected(model: AccountGroupModelType)
}

final class AccountsListCoordinator: BaseCoordinator<AccountsListCoordinationResult> {
    
    private let presentingViewController: UIViewController
    private let dependencyContainer: DependencyContainer
    
    private var viewController: AccountsListViewController!
    
    private let bag = DisposeBag()
    
    init(presentingViewController: UIViewController, dependencyContainer: DependencyContainer) {
        self.presentingViewController = presentingViewController
        self.dependencyContainer = dependencyContainer
    }
    
    override func start() -> Observable<AccountsListCoordinationResult> {
        guard let viewModel = try? dependencyContainer.resolve() as AccountsListViewModelType else { return Observable.never() }
                
        viewModel.coordination.openAddEditAccount
            .flatMap{ [unowned self] in self.coordinateToAddEditAccount($0) }
            .bind(to: viewModel.input.addEditAccountResult)
            .disposed(by: bag)
        
        viewController = AccountsListViewController.instantiate()
        viewController.bind(to: viewModel)
        presentingViewController.present(viewController, animated: true)
        
        return viewModel.coordination
            .completeCoordinationResult
            .take(1)
            .do(onNext: { [weak self] _ in self?.viewController.dismiss(animated: true) })
    }
    
    // MARK: - Coordination
    private func coordinateToAddEditAccount(_ state: AddEditAccountSceneState) -> Observable<AddEditAccountCoordinationResult> {
        let coordinator = AddEditAccountCoordinator(state: state,
                                                    presentingViewController: viewController,
                                                    dependencyContainer: dependencyContainer)
        return coordinate(to: coordinator)
    }
}
