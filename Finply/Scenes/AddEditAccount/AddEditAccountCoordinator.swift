//  
//  AddEditAccountCoordinator.swift
//  Finply
//
//  Created by Illia Postoienko on 10.11.2020.
//

import UIKit
import RxSwift
import Dip

enum AddEditAccountCoordinationResult {
    case close
    case accountAdded(FPAccount)
    case accountEdited(FPAccount)
}

final class AddEditAccountCoordinator: BaseCoordinator<AddEditAccountCoordinationResult> {
    
    let accountToEdit: FPAccount?
    let presentingViewController: UIViewController
    let dependencyContainer: DependencyContainer
    
    init(accountToEdit: FPAccount?, presentingViewController: UIViewController, dependencyContainer: DependencyContainer) {
        self.accountToEdit = accountToEdit
        self.presentingViewController = presentingViewController
        self.dependencyContainer = dependencyContainer
    }
    
    override func start() -> Observable<AddEditAccountCoordinationResult> {
        
        guard let viewModel = try? dependencyContainer.resolve() as AddEditAccountViewModelType else { return Observable.never() }
        var vc = BaseModalViewController.instantiate()
        vc.bind(to: viewModel)
        
        accountToEdit.map{ viewModel.setupAccountToEdit($0) }
        
        vc.modalPresentationStyle = .overFullScreen
        presentingViewController.present(vc, animated: true)
        
        return Observable.merge(
            [
                viewModel.coordination.close.map{ .close },
                viewModel.coordination.accountComplete.map{ [accountToEdit] in
                    accountToEdit == nil
                        ? .accountAdded($0)
                        : .accountEdited($0)
                }
            ])
            .take(1)
            .do(onNext: { [vc] _ in vc.dismiss(animated: true) })
    }
}
