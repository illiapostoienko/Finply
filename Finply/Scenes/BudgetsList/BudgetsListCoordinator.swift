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
    private var budgetsListVc: BudgetsListViewController

    init(budgetsListVc: BudgetsListViewController, dependencyContainer: DependencyContainer) {
        self.budgetsListVc = budgetsListVc
        self.dependencyContainer = dependencyContainer
    }

    override func start() -> Observable<Void> {
        
        guard let viewModel = try? dependencyContainer.resolve() as BudgetsListViewModelType else { return Observable.never() }

        budgetsListVc.bind(to: viewModel)
        
        // TODO: All returnings from VM converted to coordination result
        
        return Observable.never()
    }
}
