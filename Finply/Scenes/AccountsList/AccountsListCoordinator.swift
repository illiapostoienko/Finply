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
    let dependencyContainer: DependencyContainer
    
    init(presentingViewController: UIViewController, dependencyContainer: DependencyContainer) {
        self.presentingViewController = presentingViewController
        self.dependencyContainer = dependencyContainer
    }
    
    override func start() -> Observable<AccountsListCoordinationResult> {
        
        guard let viewModel = try? dependencyContainer.resolve() as AccountsListViewModelType else { return Observable.never() }
        var vc = AccountsListViewController.instantiate()
        vc.bind(to: viewModel)
        
        vc.modalPresentationStyle = .overFullScreen
        presentingViewController.present(vc, animated: true)
        
        // TODO: All returnings from VM converted to coordination result
        
        return Observable.never()
    }
}
