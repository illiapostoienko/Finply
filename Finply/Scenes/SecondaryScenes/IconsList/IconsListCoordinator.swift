//  
//  IconsListCoordinator.swift
//  Finply
//
//  Created by Illia Postoienko on 23.12.2020.
//

import UIKit
import RxSwift
import Dip

enum IconsListCoordinationResult {
    case close
    case selectedIcon
}

final class IconsListCoordinator: BaseCoordinator<IconsListCoordinationResult> {
    
    let presentingViewController: UIViewController
    let dependencyContainer: DependencyContainer
    
    init(presentingViewController: UIViewController, dependencyContainer: DependencyContainer) {
        self.presentingViewController = presentingViewController
        self.dependencyContainer = dependencyContainer
    }
    
    override func start() -> Observable<IconsListCoordinationResult> {
        
        guard let viewModel = try? dependencyContainer.resolve() as IconsListViewModelType else { return Observable.never() }
        var vc = IconsListViewController.instantiate()
        vc.bind(to: viewModel)
        
        presentingViewController.present(vc, animated: true)
        
        // TODO: All returnings from VM converted to coordination result
        
        return Observable.never()
    }
}
