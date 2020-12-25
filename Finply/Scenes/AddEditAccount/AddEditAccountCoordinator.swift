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
    case accountAdded(AccountDto)
    case accountEdited(AccountDto)
    case accountGroupAdded(AccountGroupDto)
    case accountGroupEdited(AccountGroupDto)
}

enum AddEditAccountSceneState {
    case addAccount
    case addAccountGroup
    case editAccount(AccountDto)
    case editAccountGroup(AccountGroupDto)
}

final class AddEditAccountCoordinator: BaseCoordinator<AddEditAccountCoordinationResult> {
    
    let state: AddEditAccountSceneState
    let presentingViewController: UIViewController
    let dependencyContainer: DependencyContainer
    
    private var viewController: AddEditAccountViewController!
    
    private let bag = DisposeBag()
    
    init(state: AddEditAccountSceneState, presentingViewController: UIViewController, dependencyContainer: DependencyContainer) {
        self.state = state
        self.presentingViewController = presentingViewController
        self.dependencyContainer = dependencyContainer
    }
    
    override func start() -> Observable<AddEditAccountCoordinationResult> {
        
        guard let viewModel = try? dependencyContainer.resolve() as AddEditAccountViewModelType else { return Observable.never() }
        
        viewModel.setup(with: state)
        
        viewModel.coordination.openCurrencyList
            .flatMap{ [unowned self] in self.coordinateToCurrencyList() }
            .bind(to: viewModel.input.currencyListResult)
            .disposed(by: bag)
        
        viewModel.coordination.openColorSelection
            .flatMap{ [unowned self] in self.coordinateToColorSetsList() }
            .bind(to: viewModel.input.colorSetsListResult)
            .disposed(by: bag)
        
        viewModel.coordination.openIconSelection
            .flatMap{ [unowned self] in self.coordinateToIconsList() }
            .bind(to: viewModel.input.iconsListResult)
            .disposed(by: bag)
        
        viewController = AddEditAccountViewController.instantiate()
        viewController.bind(to: viewModel)
        presentingViewController.present(viewController, animated: true)
        
        return viewModel.coordination
            .completeCoordinationResult
            .take(1)
            .do(onNext: { [weak self] _ in self?.viewController.dismiss(animated: true) })
    }
    
    private func coordinateToCurrencyList() -> Observable<CurrencyListCoordinationResult> {
        let coordinator = CurrencyListCoordinator(presentingViewController: viewController,
                                                  dependencyContainer: dependencyContainer)
        return coordinate(to: coordinator)
    }
    
    private func coordinateToIconsList() -> Observable<IconsListCoordinationResult> {
        let coordinator = IconsListCoordinator(presentingViewController: viewController,
                                                  dependencyContainer: dependencyContainer)
        return coordinate(to: coordinator)
    }
    
    private func coordinateToColorSetsList() -> Observable<ColorSetsListCoordinationResult> {
        let coordinator = ColorSetsListCoordinator(presentingViewController: viewController,
                                                  dependencyContainer: dependencyContainer)
        return coordinate(to: coordinator)
    }
}
