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
    case accountsGroupSelected(model: AccountGroupModelType)
}

final class AccountsListCoordinator: BaseCoordinator<AccountsListCoordinationResult> {
    
    private let presentingViewController: UIViewController
    private let transitionDelegate: PushTransitionDelegate
    private let dependencyContainer: DependencyContainer
    
    private var viewController: AccountsListViewController!
    
    private let bag = DisposeBag()
    
    init(presentingViewController: UIViewController, transitionDelegate: PushTransitionDelegate, dependencyContainer: DependencyContainer) {
        self.presentingViewController = presentingViewController
        self.transitionDelegate = transitionDelegate
        self.dependencyContainer = dependencyContainer
    }
    
    override func start() -> Observable<AccountsListCoordinationResult> {
        
        guard let viewModel = try? dependencyContainer.resolve() as AccountsListViewModelType else { return Observable.never() }
        viewController = AccountsListViewController.instantiate()
        viewController.bind(to: viewModel)
        
        presentingViewController.present(viewController, animated: true)
        
        viewModel.coordination.addAccount
            .flatMap{ [unowned self] _ in self.coordinateToAddEditAccount() }
            .subscribe(onNext: {
                switch $0 {
                case .accountAdded(let model): return // pass to vm
                default: return
                }
            })
            .disposed(by: bag)
        
        viewModel.coordination.editAccount
            .flatMap{ [unowned self] in self.coordinateToAddEditAccount(accountToEdit: $0) }
            .subscribe(onNext: {
                switch $0 {
                case .accountEdited(let model): return // pass to vm
                default: return
                }
            })
            .disposed(by: bag)
        
//        viewModel.coordination.addAccountGroup -> coordinate
//        viewModel.coordination.editAccountGroup
        
        return Observable.merge(
            [
                viewModel.coordination.back.map{ .back },
                viewModel.coordination.accountSelected.map{ .accountSelected(model: $0) },
                viewModel.coordination.accountGroupSelected.map{ .accountsGroupSelected(model: $0) }
            ])
            .take(1)
            .do(onNext: { [weak self] _ in self?.viewController.dismiss(animated: true) })
    }
    
    // MARK: - Coordination
    private func coordinateToAddEditAccount(accountToEdit: AccountModelType? = nil) -> Observable<AddEditAccountCoordinationResult> {
        let coordinator = AddEditAccountCoordinator(accountToEdit: accountToEdit,
                                                    presentingViewController: viewController,
                                                    dependencyContainer: dependencyContainer)
        return coordinate(to: coordinator)
    }
    
//    private func coordinateToAddEditAccountGroup(accountToEdit: FPAccountGroup? = nil) -> Observable<AddEditAccountGroupCoordinationResult> {
//        let coordinator = AddEditAccountGroupCoordinator(accountToEdit: accountToEdit,
//                                                    presentingViewController: viewController,
//                                                    dependencyContainer: dependencyContainer)
//        return coordinate(to: coordinator)
//    }
}
