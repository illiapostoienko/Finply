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
    case cancel
    case accountSelected
    case accountsGroupSelected
}

final class AccountsListCoordinator: BaseCoordinator<AccountsListCoordinationResult> {
    
    let presentingViewController: UIViewController
    let transitionDelegate: PushTransitionDelegate
    let dependencyContainer: DependencyContainer
    
    init(presentingViewController: UIViewController, transitionDelegate: PushTransitionDelegate, dependencyContainer: DependencyContainer) {
        self.presentingViewController = presentingViewController
        self.transitionDelegate = transitionDelegate
        self.dependencyContainer = dependencyContainer
    }
    
    override func start() -> Observable<AccountsListCoordinationResult> {
        
        guard let viewModel = try? dependencyContainer.resolve() as AccountsListViewModelType else { return Observable.never() }
        var vc = AccountsListViewController.instantiate()
        vc.bind(to: viewModel)
        
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = transitionDelegate
        presentingViewController.present(vc, animated: true)
        
        let cancel = viewModel.backButtonTap.map{ AccountsListCoordinationResult.cancel }
        
        let viewModelReturnStream = Observable.merge(cancel /* other returnings*/)
            .take(1)
            .do(onNext: { [vc] _ in vc.dismiss(animated: true) })
        
        return Observable.merge(viewModelReturnStream).take(1)
    }
}
