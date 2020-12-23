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
    private let dependencyContainer: DependencyContainer
    
    private var viewController: AccountsListViewController!
    
    private let bag = DisposeBag()
    
    init(presentingViewController: UIViewController, dependencyContainer: DependencyContainer) {
        self.presentingViewController = presentingViewController
        self.dependencyContainer = dependencyContainer
    }
    
    override func start() -> Observable<AccountsListCoordinationResult> {
        guard let viewModel = try? dependencyContainer.resolve() as AccountsListViewModelType else { return Observable.never() }
        
        viewController = AccountsListViewController.instantiate()
        viewController.bind(to: viewModel)
        
        presentingViewController.present(viewController, animated: true)
        
        Observable.merge([
            viewModel.coordination.addAccount.map{ AddEditAccountSceneState.addAccount },
            viewModel.coordination.editAccount.map{ AddEditAccountSceneState.editAccount($0) },
            viewModel.coordination.addAccountGroup.map{ AddEditAccountSceneState.addAccountGroup },
            viewModel.coordination.editAccountGroup.map{ AddEditAccountSceneState.editAccountGroup($0) }
        ])
        .flatMap{ [unowned self] in self.coordinateToAddEditAccount($0) }
        .subscribe(onNext: {
            switch $0 {
            case .accountAdded(let addedAccount): return // add to vm
            case .accountEdited(let editedAccount): return // edit in vm
            case .accountGroupAdded(let addedAccountGroup): return // add to vm
            case .accountGroupEdited(let editedAccountGroup): return // edit in vm
            default: return
            }
        })
        .disposed(by: bag)
        
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
    private func coordinateToAddEditAccount(_ state: AddEditAccountSceneState) -> Observable<AddEditAccountCoordinationResult> {
        let coordinator = AddEditAccountCoordinator(state: state,
                                                    presentingViewController: viewController,
                                                    dependencyContainer: dependencyContainer)
        return coordinate(to: coordinator)
    }
}
