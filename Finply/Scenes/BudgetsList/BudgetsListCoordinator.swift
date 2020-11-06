//  
//  BudgetsListCoordinator.swift
//  Finply
//
//  Created by Illia Postoienko on 06.11.2020.
//

import UIKit
import RxSwift
import Dip

final class BudgetsListCoordinator: BaseCoordinator<Void> {
    
    let dependencyContainer: DependencyContainer
    private(set) var viewController = BudgetsListViewController.instantiate()
    
    init(dependencyContainer: DependencyContainer) {
        self.dependencyContainer = dependencyContainer
    }
    
    override func start() -> Observable<Void> {
        
        guard let viewModel = try? dependencyContainer.resolve() as BudgetsListViewModelType else { return Observable.never() }

        viewController.bind(to: viewModel)
        
        // TODO: All returnings from VM converted to coordination result
        
        return Observable.never()
    }
}
