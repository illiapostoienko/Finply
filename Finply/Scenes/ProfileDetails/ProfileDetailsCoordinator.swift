//  
//  ProfileDetailsCoordinator.swift
//  Finply
//
//  Created by Illia Postoienko on 10.11.2020.
//

import UIKit
import RxSwift
import Dip

enum ProfileDetailsCoordinationResult {
    case cancel
}

final class ProfileDetailsCoordinator: BaseCoordinator<ProfileDetailsCoordinationResult> {
    
    let presentingViewController: UIViewController
    let dependencyContainer: DependencyContainer
    
    init(presentingViewController: UIViewController, dependencyContainer: DependencyContainer) {
        self.presentingViewController = presentingViewController
        self.dependencyContainer = dependencyContainer
    }
    
    override func start() -> Observable<ProfileDetailsCoordinationResult> {
        
        guard let viewModel = try? dependencyContainer.resolve() as ProfileDetailsViewModelType else { return Observable.never() }
        var vc = ProfileDetailsViewController.instantiate()
        vc.bind(to: viewModel)
        
        presentingViewController.present(vc, animated: true)
        
        // TODO: All returnings from VM converted to coordination result
        
        return Observable.never()
    }
}
