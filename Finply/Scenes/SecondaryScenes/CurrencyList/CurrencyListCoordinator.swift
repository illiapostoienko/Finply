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
    
    let selectedCurrency: Currency
    let presentingViewController: UIViewController
    let dependencyContainer: DependencyContainer
    private var viewController: CurrencyListViewController!
    
    init(selectedCurrency: Currency, presentingViewController: UIViewController, dependencyContainer: DependencyContainer) {
        self.selectedCurrency = selectedCurrency
        self.presentingViewController = presentingViewController
        self.dependencyContainer = dependencyContainer
    }
    
    override func start() -> Observable<CurrencyListCoordinationResult> {
        viewController = CurrencyListViewController.instantiate()
        viewController.setSelected(currency: selectedCurrency)
        
        presentingViewController.present(viewController, animated: true)
        
        return viewController.completeCoordinationResult
            .take(1)
            .do(onNext: { [weak self] _ in self?.viewController.dismiss(animated: true) })
    }
}
