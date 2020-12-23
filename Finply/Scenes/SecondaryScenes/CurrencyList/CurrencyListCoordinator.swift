//  
//  CurrencyListCoordinator.swift
//  Finply
//
//  Created by Illia Postoienko on 21.12.2020.
//

import UIKit
import RxSwift
import Dip

enum CurrencyListCoordinationResult {
    case close
    case selectedCurrency(Currency)
}

final class CurrencyListCoordinator: BaseCoordinator<CurrencyListCoordinationResult> {
    
    let presentingViewController: UIViewController
    let dependencyContainer: DependencyContainer
    
    init(presentingViewController: UIViewController, dependencyContainer: DependencyContainer) {
        self.presentingViewController = presentingViewController
        self.dependencyContainer = dependencyContainer
    }
    
    override func start() -> Observable<CurrencyListCoordinationResult> {
        
        guard let viewModel = try? dependencyContainer.resolve() as CurrencyListViewModelType else { return Observable.never() }
        var vc = CurrencyListViewController.instantiate()
        vc.bind(to: viewModel)
        
        presentingViewController.present(vc, animated: true)
        
        // TODO: All returnings from VM converted to coordination result
        
        return Observable.never()
    }
}
