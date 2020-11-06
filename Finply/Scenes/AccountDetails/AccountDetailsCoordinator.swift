//  
//  AccountDetailsCoordinator.swift
//  Finply
//
//  Created by Illia Postoienko on 06.11.2020.
//

import UIKit
import RxSwift
import Dip

final class AccountDetailsCoordinator: BaseCoordinator<Void> {
    
    let dependencyContainer: DependencyContainer
    private(set) var viewController = AccountDetailsViewController.instantiate()
    
    init(dependencyContainer: DependencyContainer) {
        self.dependencyContainer = dependencyContainer
    }
    
    override func start() -> Observable<Void> {
        
        guard let viewModel = try? dependencyContainer.resolve() as AccountDetailsViewModelType else { return Observable.never() }

        viewController.bind(to: viewModel)
        

        return Observable.never()
    }
}
